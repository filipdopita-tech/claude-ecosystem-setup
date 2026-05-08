# Data Growth OS Output Schemas

## Lead Row

Required fields:

```csv
dedupe_key,company_name,ico,domain,person_name,role,email,phone,city,country,source_name,source_url,captured_at,method,signal,score,confidence,legal_basis_note,do_not_contact_reason,last_contacted_at,raw_evidence_path,notes
```

Rules:

- `dedupe_key`: prefer `ico`, then domain, then normalized company+city.
- `score`: 0-100, explain in report.
- `confidence`: `high`, `medium`, `low`.
- `do_not_contact_reason`: empty only if no blocker found.

## Ads Intelligence Row

```csv
competitor,platform,ad_id,ad_url,landing_url,captured_at,format,hook,offer,proof,cta,angle,creative_notes,evidence_path,confidence,notes
```

Rules:

- Separate observed copy from interpretation.
- Store screenshots or public ad URLs where possible.
- Never infer spend unless the platform reports it.

## Source Ledger

```csv
source_name,source_url,access_method,risk_tier,cost_tier,allowed,blocked_reason,rate_limit_note,last_checked_at,owner,notes
```

Risk tiers:

- `safe_public`
- `controlled_provider`
- `manual_gate`
- `hard_stop`

Cost tiers:

- `free`
- `metered`
- `subscription`
- `unknown`

## Report Skeleton

```markdown
# Data Growth Report: <topic>

Generated: <ISO timestamp>

## Summary

## Scope

## Sources

## Results

## Verification

## Coverage Gaps

## Next Actions

## Residual Risk
```
