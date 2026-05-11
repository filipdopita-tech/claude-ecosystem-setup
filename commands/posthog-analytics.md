---
name: posthog-analytics
description: Query product events, funnels, and feature flags via PostHog API. Triggers on analytics, events, PostHog, funnel, conversion rate, feature flag. Covers HogQL, retention cohorts, and marketing metrics for creator and SaaS workflows.
allowed-tools: [Bash, Read]
last-updated: 2026-04-27
version: 1.0.0
---

# PostHog Analytics

Query product events, funnels, retention, and feature flags via HogQL. Zero setup for event capture; focus on insights.

## Setup

Authenticate:
```bash
export POSTHOG_API_KEY="phc_xxx"  # Project API key from PostHog UI
export POSTHOG_PROJECT_ID="12345"
POSTHOG_HOST="https://us.posthog.com"  # or self-hosted instance
```

## HogQL Query Patterns

All queries use REST endpoint:
```bash
curl -s "$POSTHOG_HOST/api/projects/$POSTHOG_PROJECT_ID/query/" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT ..."
    }
  }' | jq '.results'
```

### 1. Event Count by Day (Last 7 Days)

```sql
SELECT
  toDate(timestamp) AS day,
  event,
  COUNT() AS count
FROM events
WHERE timestamp >= now() - INTERVAL 7 DAY
GROUP BY day, event
ORDER BY day DESC, count DESC
```

Use case: Check if tracking is working, spot traffic spikes.

### 2. Funnel Conversion (Signup → Activation)

```sql
SELECT
  step_0 as signed_up,
  step_1 as started_tutorial,
  step_2 as completed_first_upload,
  step_3 as invited_team,
  COUNT(*) as count
FROM events_funnel(
  [
    {event: 'user_signup'},
    {event: 'tutorial_started'},
    {event: 'upload_completed'},
    {event: 'team_invited'}
  ],
  INTERVAL 7 DAY
)
GROUP BY step_0, step_1, step_2, step_3
ORDER BY count DESC
```

Computes drop-off at each stage. Key metric for creator onboarding.

### 3. Retention Cohort (7-Day Cohort)

```sql
SELECT
  cohort_key,
  day,
  COUNT(DISTINCT person_id) as retained
FROM cohort_retention(
  'user_signup',
  7  -- cohort size in days
)
WHERE cohort_day <= 30  -- analyze 30 days post-signup
GROUP BY cohort_key, day
ORDER BY cohort_key, day
```

Shows N-day retention: % of users returning after signup. Target 30%+ D7 retention for SaaS.

### 4. Feature Flag Usage (A/B Test)

```sql
SELECT
  COALESCE(
    properties->>'$feature_flag_response',
    'control'
  ) as variant,
  COUNT(DISTINCT person_id) as users,
  COUNT() as events
FROM events
WHERE event = '$feature_flag_called'
  AND properties->>'$feature_flag' = 'new_dashboard'
  AND timestamp >= now() - INTERVAL 7 DAY
GROUP BY variant
ORDER BY users DESC
```

Breakdown of experiment variants. Use to decide rollout.

### 5. Top Conversion Paths (Marketing to Purchase)

```sql
SELECT
  sequence,
  COUNT() as count
FROM (
  SELECT
    person_id,
    arrayStringConcat(
      arrayMap(x -> x.1, groupArray((event, timestamp))),
      ' -> '
    ) as sequence
  FROM events
  WHERE timestamp >= now() - INTERVAL 30 DAY
    AND event IN ('page_view', 'cta_clicked', 'pricing_viewed', 'signup')
  GROUP BY person_id
) journeys
WHERE sequence LIKE '%pricing_viewed%signup%'
GROUP BY sequence
ORDER BY count DESC
LIMIT 10
```

Identifies successful user journeys. Optimize marketing funnel based on top paths.

## REST API Patterns

### Query with Dashboard-Style Insight

Shorthand for common questions:

```bash
curl -s "$POSTHOG_HOST/api/projects/$POSTHOG_PROJECT_ID/insights/" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Daily Events",
    "query": {
      "kind": "EventsQuery",
      "data": {
        "kind": "EventsQuery",
        "select": ["count()", "event"],
        "where": ["timestamp > yesterday()"],
        "group_by": ["toDate(timestamp)", "event"]
      }
    }
  }' | jq '.results'
```

### Feature Flag Check (Client-Side Safe)

Decide variant without querying entire events table:

```bash
curl -s "$POSTHOG_HOST/api/feature_flags/determine/?v=2" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "distinct_id": "user_123",
    "groups": {
      "organization": "acme_corp"
    }
  }' | jq '.featureFlags | .{new_dashboard, advanced_export}'
```

Returns: `{"new_dashboard": true, "advanced_export": false}` or similar.

### Create / Trigger Feature Flag

```bash
curl -X POST "$POSTHOG_HOST/api/projects/$POSTHOG_PROJECT_ID/feature_flags/" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "new_dashboard",
    "key": "new_dashboard",
    "filters": {
      "groups": [
        {
          "properties": [
            {
              "key": "email",
              "value": ["@company.com"],
              "operator": "icontains"
            }
          ]
        }
      ]
    },
    "rollout_percentage": 50
  }'
```

Deploy flag targeting 50% of employees. Increase rollout_percentage over days to 100%.

## Common Metrics for Creator Stack

### Signup to Trial Activation (D1)

```sql
SELECT
  COUNT(DISTINCT CASE WHEN step_1 IS NOT NULL THEN person_id END) / 
  COUNT(DISTINCT person_id) as d1_activation
FROM events_funnel(
  [
    {event: 'user_signup'},
    {event: 'first_project_created'}
  ],
  INTERVAL 1 DAY
)
```

Target: 40%+ of signups create first asset by D1.

### Marketing Campaign Attribution

```sql
SELECT
  properties->>'utm_source' as source,
  properties->>'utm_campaign' as campaign,
  COUNT(DISTINCT person_id) as signups,
  SUM(CASE WHEN properties->>'$paying' THEN 1 ELSE 0 END) as paid,
  ROUND(100.0 * SUM(CASE WHEN properties->>'$paying' THEN 1 ELSE 0 END) / COUNT(DISTINCT person_id), 2) as paid_pct
FROM events
WHERE event = 'user_signup'
  AND timestamp >= now() - INTERVAL 90 DAY
GROUP BY source, campaign
ORDER BY signups DESC
```

Shows CAC by channel and conversion-to-paid per channel.

### Team Invite (Viral Loop Metric)

```sql
SELECT
  COUNT(DISTINCT person_id) as users_inviting,
  SUM(
    toInt(arrayLength(
      splitByString(',', properties->>'invited_emails')
    ))
  ) as total_invites,
  ROUND(total_invites / NULLIF(users_inviting, 0), 2) as invites_per_user
FROM events
WHERE event = 'team_invite_sent'
  AND timestamp >= now() - INTERVAL 30 DAY
```

Measure viral coefficient. >1.2 invites/user = strong viral loop.

## Cost & Limits

**Free Tier:**
- 1M events/month
- 1 project, unlimited users
- 7-day retention
- No support

**Pro:**
- 50M events/month = $50/mo base
- 365-day retention
- Feature flags, flags with conditions
- API access, webhooks

Creator typical: 200k–2M events/mo depending on feature usage.

## Bash Integration

### Wrapper for Safe Queries

```bash
#!/bin/bash
# posthog-query.sh — run HogQL with error handling

if [[ -z "$POSTHOG_API_KEY" || -z "$POSTHOG_PROJECT_ID" ]]; then
  echo "Missing POSTHOG_API_KEY or POSTHOG_PROJECT_ID" >&2
  exit 1
fi

query="$1"
response=$(curl -s \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": {\"kind\": \"HogQLQuery\", \"query\": \"$query\"}}" \
  "https://us.posthog.com/api/projects/$POSTHOG_PROJECT_ID/query/")

echo "$response" | jq '.results'
```

Usage:
```bash
./posthog-query.sh "SELECT event, COUNT() FROM events GROUP BY event"
```

## Integration with Marketing Funnel Audit

In `commands/competitor-snapshot.md`, call after screenshot:

```bash
# Snapshot conversion metrics
posthog-query "SELECT COUNT(DISTINCT person_id) as signups FROM events WHERE event='user_signup' AND timestamp > now() - 30 DAY"

# Compare traffic last 7 days vs 14 days prior
```

Pass results to `marketing-funnel-audit` agent for narrative insights.
