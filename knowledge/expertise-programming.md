# Expertise: Pokročilé programování & Systémový design
# Stack: Python, TypeScript, PostgreSQL, Redis, Docker | Updated: 2026-04

## 1. SYSTEM DESIGN — DECISION FRAMEWORK

### Kdy použít co
```
Data jsou relační s transakcemi?      → PostgreSQL
Cache / session / job queue?          → Redis
Operace > 500ms nebo může selhat?     → Async queue (Celery/BullMQ)
Traffic > 10k req/s?                  → Cache + read replicas + PgBouncer
Finance/inventář (accuracy first)?    → CP systém, strong consistency
Social feed/analytics (uptime first)? → AP systém, eventual consistency
Horizontal scaling nutný?             → Stateless app + session v Redis
```

### Load balancing
- L4 (TCP): raw throughput, nevidí HTTP kontext
- L7 (HTTP): routing podle URL/header/cookie — výchozí volba
- Algoritmy: round robin → weighted → least-connections → latency-based
- Health checks každých 5-10s, circuit breaker po 3+ selhání za 60s

### Database scaling progression
1. Vertical (jednoduché, má strop, SPOF)
2. Read replicas + PgBouncer — scale reads
3. Pool size: `(CPU cores * 2) + spindles` — nepřekračuj 100 conn/DB
4. Sharding: user_id % N / geography — hard to rebalance
5. Federation: rozdělení DB podle domény

### Caching layers
```
Browser → CDN → Reverse proxy → Application (Redis) → DB
```
- Cache-aside (lazy): nejběžnější, staleness risk — TTL 5min-1h
- Write-through: po každém write update cache — pro frequently-read data
- Write-behind: async DB flush — fast writes, risk ztráty dat

---

## 2. DESIGN PATTERNS — KDY KTERÝ

| Pattern | Použij když |
|---|---|
| **Strategy** | Více algoritmů pro stejný úkol (pricing, sort, auth) |
| **Observer** | Více komponent reaguje na změnu stavu (pub/sub) |
| **Factory Method** | Oddělit vytváření od použití, testovatelnost |
| **Builder** | Objekt s 4+ volitelnými parametry |
| **Decorator** | Dynamicky přidat chování (middleware, retry, logging) |
| **Adapter** | Integrace nekompatibilního rozhraní (legacy, 3rd party) |
| **Repository** | Testovatelný přístup k datům (mock v testech) |
| **Command** | Undo/redo, frontování operací, audit log |
| **Facade** | Zjednodušit komplexní subsystém |
| **State** | Objekt mění chování podle vnitřního stavu (FSM) |

### Anti-patterns
- God Object, Singleton na vše (→ DI), Premature optimization
- Distributed monolith (microservices se sync HTTP na každý request)
- Anemic Domain Model (logika rozházena po services)

---

## 3. PYTHON POKROČILÉ VZORY

### Async/await
```python
# Paralelní I/O
results = await asyncio.gather(fetch(url1), fetch(url2), fetch(url3))

# Timeout
async with asyncio.timeout(5.0):
    result = await slow_operation()

# CHYBA: time.sleep() a requests.get() blokují event loop
# FIX: await asyncio.sleep() a aiohttp.ClientSession
```
- Async = I/O-bound (síť, disk) — CPU-bound → multiprocessing/ProcessPoolExecutor

### Retry decorator s exponential backoff
```python
def retry(times=3, delay=1.0, exceptions=(Exception,)):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(times):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == times - 1: raise
                    time.sleep(delay * (2 ** attempt))
        return wrapper
    return decorator
```

### Dataclasses + Protocol
```python
@dataclass(frozen=True)  # immutable DTO
class UserId:
    value: int

class Repository(Protocol[T]):
    def get(self, id: int) -> T | None: ...
    def save(self, entity: T) -> T: ...
```

---

## 4. TYPESCRIPT POKROČILÉ VZORY

### Utility types
```typescript
type CreateUser  = Omit<User, 'id'>
type UpdateUser  = Partial<Pick<User, 'name' | 'email'>>
type UserRole    = User['role']
type RoleMap     = Record<User['role'], string[]>
```

### Discriminated unions + exhaustive check
```typescript
type ApiState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string; code: number }

function assertNever(x: never): never { throw new Error('Unhandled case') }
```

### Branded types
```typescript
type UserId = number & { readonly __brand: 'UserId' }
const asUserId = (id: number): UserId => id as UserId
```

### Zod — runtime validation + type inference
```typescript
const UserSchema = z.object({
  id: z.number().positive(),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
})
type User = z.infer<typeof UserSchema>

// Na API hranici
const result = UserSchema.safeParse(req.body)
if (!result.success) return res.status(400).json(result.error.flatten())
```

---

## 5. POSTGRESQL OPTIMALIZACE

### Index typy
| Index | Použij pro |
|---|---|
| B-Tree (default) | Equality, range, ORDER BY |
| Hash | Equality only — rychlejší přesný match |
| GIN | JSONB (@>), arrays, full-text (tsvector) |
| BRIN | Obří tabulky s přirozeným pořadím (timestamps) |
| Partial | `WHERE status = 'active'` — menší index |
| Covering | `INCLUDE (col)` — index-only scan, bez heap fetch |

### Query patterns
```sql
-- Expression index (umožní index na funkci)
CREATE INDEX ON users (LOWER(email));

-- Partial index pro subset
CREATE INDEX CONCURRENTLY ON orders (user_id)
WHERE status IN ('pending', 'processing');

-- Cursor paginace místo OFFSET
WHERE created_at < $cursor ORDER BY created_at DESC LIMIT 20

-- Covering index
CREATE INDEX ON orders (user_id) INCLUDE (status, total, created_at);
```

### EXPLAIN ANALYZE — čtení
```
Seq Scan       → chybí index nebo low selectivity
Index Only Scan → nejlepší (covering index funguje)
Nested Loop    → ok pro malé sety, špatné pro velké
```
- `cost=X..Y`: Y = total cost, nižší lepší
- `rows=N actual rows=M`: velký rozdíl → ANALYZE pro update statistik

### Connection pooling
- PgBouncer v transaction mode: 1 DB connection obsluhuje N app connections
- Pool size: `(CPU cores * 2) + spindles` — max 100 přímých DB connections
- Timeout acquire: 5s max, jinak fail fast

---

## 6. REDIS PATTERNS

### Datová struktura pro use case
```
Cache objektu:     HSET user:123 field value  (partial updates)
Session / token:   SET session:token data EX 86400
Rate limit čítač:  INCR user:123:reqs  (atomic)
Job queue:         LPUSH jobs:email payload / RPOP
Unique visitors:   SADD visitors:2026-04-03 user_id
Leaderboard:       ZADD scores score member
```

### Rate limiting — Lua atomic
```lua
local current = redis.call('incr', KEYS[1])
if current == 1 then redis.call('expire', KEYS[1], ARGV[1]) end
return current <= tonumber(ARGV[2])
```

### Distributed lock
```python
token = str(uuid.uuid4())
acquired = redis.set(f"lock:{resource}", token, nx=True, ex=30)
# Release pres Lua script — atomicky check + delete
RELEASE = "if redis.call('get',KEYS[1])==ARGV[1] then return redis.call('del',KEYS[1]) end return 0"
redis.eval(RELEASE, 1, f"lock:{resource}", token)
```

### Cache invalidation
- TTL-based: pro data menici se zridka (< 1x/hod)
- Event-based: DEL klic pri kazdem write
- Nikdy bez TTL — memory leak
- Max memory policy: `allkeys-lru` pro cache, `noeviction` pro session

### Key naming: `namespace:object:id[:field]`

---

## 7. SECURITY CHECKLIST

### Autentizace
- bcrypt (cost 12) nebo argon2id — nikdy MD5/SHA1/plain
- Min 12 znaků, HaveIBeenPwned check
- Rate limit: 5 pokusu / 15 min / IP + account lockout
- Session: min 128 bitu entropie, HttpOnly + Secure + SameSite=Strict
- JWT: kratka expirace (15min access / 7d refresh), RS256 pro multi-service

### OWASP Top 10 — checklist
1. **Broken Access Control** — overuj opravneni kazdy request, RBAC
2. **Cryptographic Failures** — TLS 1.2+, sifruj PII, zadne slabe hashe
3. **Injection** — parametrizovane queries, nikdy string concat
4. **Insecure Design** — threat modeling, abuse cases
5. **Security Misconfiguration** — debug=False v prod, change defaults
6. **Vulnerable Components** — Dependabot, pip-audit, npm audit v CI
7. **Auth Failures** — viz checklist vyse
8. **Integrity Failures** — checksumy, podpisuj CI/CD artifacts
9. **Logging Failures** — loguj auth events, NIKDY secrets v logu
10. **SSRF** — allowlistuj URL, blokuj internal IP ranges

### API security
- CORS: explicitni allowlist, ne `*` v produkci
- Rate limiting: per user (Redis) + per IP
- Secrets: env promenne nebo vault, nikdy v kodu

---

## 8. API DESIGN

### REST — metody a kody
```
GET /users         → 200 + cursor pagination
POST /users        → 201 + Location: /users/{id}
PATCH /users/{id}  → 200 (partial update)
DELETE /users/{id} → 204 No Content
POST /orders/{id}/cancel  (akce jako sub-resource)
```

### Error response
```json
{"error": {"code": "VALIDATION_ERROR", "message": "...",
 "details": [{"field": "email", "message": "Invalid format"}]}}
```
- 400 (validation), 401 (authn), 403 (authz), 409 (conflict), 422, 429, 500

### Versioning: `/api/v1/` — Sunset header + 6 mesicu notice

---

## 9. DOCKER / CONTAINER PATTERNS

### Multi-stage build
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY src/ .
RUN adduser --uid 1001 --no-create-home app
USER app
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

### Pravidla
- Non-root user vzdy, 1 proces per kontejner
- Immutable image: konfigurace pres env promenne
- Layer caching: COPY zavislosti PRED kodem
- Base: `slim` nebo `distroless`, nikdy `latest` v produkci
- Nikdy `--privileged` v produkci

---

## DECISION FRAMEWORK — RYCHLE VOLBY

```
Novy feature s persistenci?
  SQL (relace, transakce) vs NoSQL (schema se meni)

> 10k req/s?
  Cache (Redis) + read replicas + PgBouncer

Operace > 500ms?
  Async queue + webhook/polling pro vysledek

API vrati stejna data pro N% requestu?
  Cache response s TTL (Redis / CDN)

> 3 mista co delaji to same?
  Extrahuj jako service nebo utility

Nova trida/modul?
  SRP test: lze popsat jednou vetou bez "a"?

Novy index do DB?
  EXPLAIN ANALYZE pred a po, sleduj write overhead

Ukladas do Redis?
  TTL vzdy, spravna datova struktura, naming convention
```
