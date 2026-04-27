---
name: <service>-<action>
description: "Use when the user wants to <trigger description>. Covers <scope>."
compatibility: Requires <ENV_VAR> environment variable. Network access limited to <base_url> only.
metadata:
  requires-env: <ENV_VAR>
  allowed-hosts: <base_url>
  version: "1.0"
---

# <Service Name> Integration

## Auth
- Base URL: `<base_url>`
- Auth header: `Authorization: Bearer $<ENV_VAR>`
- Credential source: `~/.credentials/master.env` nebo `/root/.credentials/master.env`
- NIKDY hardcoded token. VŽDY `source` z env souboru.

## Endpoints

### 1. List Resources
```
GET /api/v1/resources
Headers: Authorization: Bearer $<ENV_VAR>
Response: { "data": [...], "pagination": { "page", "pageSize", "total" } }
```

### 2. Create Resource
```
POST /api/v1/resources
Headers: Authorization: Bearer $<ENV_VAR>, Content-Type: application/json
Body: { "name": "...", "config": {...} }
Response: { "id": "...", "status": "created" }
```

### 3. Async Operation (pokud API je async)
```
POST /api/v1/resources/:id/actions
Response: { "runId": "run_xxx", "status": "queued" }
```

## Async Polling Pattern

Pokud API vrací async operace (runId, jobId, taskId):

```bash
# 1. Spusť operaci
RUN_ID=$(curl -s -X POST "$BASE_URL/api/v1/action" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"input": "..."}' | jq -r '.runId')

# 2. Poll s exponential backoff
DELAY=2
MAX_DELAY=5
TIMEOUT=300  # 5 minut
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(curl -s "$BASE_URL/api/v1/runs/$RUN_ID" \
    -H "Authorization: Bearer $API_KEY" | jq -r '.status')

  case "$STATUS" in
    "completed") echo "Done"; break ;;
    "failed") echo "Failed"; exit 1 ;;
    "queued"|"running") sleep $DELAY; ELAPSED=$((ELAPSED + DELAY)); DELAY=$((DELAY < MAX_DELAY ? DELAY + 1 : MAX_DELAY)) ;;
    *) echo "Unknown status: $STATUS"; exit 1 ;;
  esac
done

[ $ELAPSED -ge $TIMEOUT ] && echo "Timeout after ${TIMEOUT}s" && exit 1
```

**Pravidla pollingu:**
- Start interval: 2s
- Max interval: 5s (backoff po 1s krocich)
- Hard timeout: 5 minut
- NIKDY busy-wait bez sleep
- NIKDY poll bez timeout limitu

## Error Handling

| HTTP Code | Meaning | Action |
|-----------|---------|--------|
| 400 | Bad request / validation | Oprav payload, neopakuj stejný |
| 401 | Invalid/expired token | Zkontroluj env var, re-source credentials |
| 403 | Insufficient permissions | Zkontroluj scopes, informuj uživatele |
| 404 | Resource not found | Ověř ID, listni existující resources |
| 429 | Rate limited | Počkej `Retry-After` header sekund, pak retry |
| 500+ | Server error | Retry max 2x s 5s pauzou, pak informuj uživatele |

## Common Mistakes (anti-hallucination)

1. **Nevymýšlej endpointy.** Používej JEN endpointy popsané v tomto dokumentu. Pokud potřebuješ endpoint který tu není, řekni to uživateli.
2. **Neházkuj response formát.** Parsuj skutečný response, nespoléhej na předpokládanou strukturu.
3. **Nepřeskakuj error handling.** Každý curl MUSÍ mít `-f` flag nebo explicitní kontrolu HTTP kódu.
4. **Neukládej API response do proměnné bez size limitu.** Velké response piš do souboru: `curl ... -o /tmp/response.json`.
5. **Nekombinuj auth metody.** Pokud je specifikován Bearer token, nepoužívej query parametry ani cookies.

## Security Constraints

- Network scope: POUZE `<base_url>` - žádné jiné domény
- Credentials: POUZE z env souboru, NIKDY z paměti nebo hardcoded
- Data: response data neloguj do stdout pokud obsahují PII
- Tokens: pokud API vrací temporary tokens, neukládej je do memory

## Pagination

Pokud API podporuje pagination:
```bash
PAGE=1
PAGE_SIZE=50
while true; do
  RESPONSE=$(curl -s "$BASE_URL/api/v1/resources?page=$PAGE&pageSize=$PAGE_SIZE" \
    -H "Authorization: Bearer $API_KEY")
  TOTAL=$(echo "$RESPONSE" | jq '.pagination.total')
  # process data...
  [ $((PAGE * PAGE_SIZE)) -ge $TOTAL ] && break
  PAGE=$((PAGE + 1))
done
```

## Checklist pred implementaci nove API skill

- [ ] API key ulozen v `~/.credentials/master.env` (chmod 600)
- [ ] Base URL v `allowed-hosts` frontmatteru
- [ ] Vsechny endpointy overeny proti skutecne API dokumentaci
- [ ] Error handling pro kazdy endpoint
- [ ] Polling pattern pokud API je async
- [ ] Rate limit handling
- [ ] Zadne hardcoded credentials
- [ ] Response parsing s jq (ne regex na JSON)
