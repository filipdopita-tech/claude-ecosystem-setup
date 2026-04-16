# GitHub Recon — Systematické hodnocení repozitářů

> Načti při: "podívej se na tento repo", "je to good?", "co si myslíš o X library", GitHub URL

## 1. Rychlý přehled (30 sekund)

```bash
gh repo view OWNER/REPO --json \
  name,description,stargazerCount,forkCount,createdAt,pushedAt,\
  primaryLanguage,licenseInfo,isArchived
```

Co hledat:
- `isArchived: true` → STOP, repo je dead
- `pushedAt` > 1 rok → warning (stagnace)
- `licenseInfo.key` → zkontroluj komerční použití (viz níže)

---

## 2. Metriky pro hodnocení

### Hvězdy
| Počet | Interpretace |
|---|---|
| < 500 | Experimentální, vysoké riziko opuštění |
| 500–2K | Viable, ale ověř contributors |
| 2K–10K | Etablovaný, community existuje |
| > 10K | Mainstream, nízké riziko |

### Star velocity (organičnost)
```bash
# Zkontroluj star history graf: https://star-history.com/#OWNER/REPO
# Nebo výpočet:
# days_alive = (dnes - createdAt) / 86400
# velocity = stars / days_alive
# < 5/den = organické | spike > 500/den bez důvodu = podezřelé
```

### Fork ratio (API stabilita)
```
fork_ratio = forkCount / stargazerCount
```
- < 5% → zdravé, lidé užívají jak je
- 5–15% → normální pro aktivní projekty
- > 20% → lidé ho hodně customizují → API nedostačující nebo nestabilní

### Open issues ratio
```bash
gh api repos/OWNER/REPO --jq '{open: .open_issues_count}'
gh api repos/OWNER/REPO/issues?state=closed\&per_page=1 \
  -H "Accept: application/vnd.github.v3+json" --jq 'length'
# open / (open + closed) < 20% = zdravé
```

---

## 3. Aktivita a mainteneři

```bash
# Poslední commity
gh api repos/OWNER/REPO/commits?per_page=5 \
  | jq '.[] | {msg: .commit.message, date: .commit.author.date, author: .commit.author.name}'

# Počet a identita contributorů
gh api repos/OWNER/REPO/contributors?per_page=15 \
  | jq '.[] | {login: .login, contributions: .contributions}'

# Otevřené issues — co lidi řeší
gh issue list -R OWNER/REPO --state open --limit 20

# PR activity — jak rychle se mergují
gh pr list -R OWNER/REPO --state merged --limit 10
```

Varovné signály:
- Single contributor + žádná odpověď na issues > 30 dní
- Closes bez komentáře ("wontfix" spam)
- Žádné releases za 6+ měsíců ale aktivní main branch

---

## 4. Licence — komerční použití

| Licence | Komerční use | Podmínky |
|---|---|---|
| **MIT** | ✅ Volně | Zachovat copyright notice |
| **Apache 2.0** | ✅ Volně | Copyright + NOTICE file + patent grant |
| **BSD 2/3** | ✅ Volně | Copyright notice |
| **ISC** | ✅ Volně | Jako MIT |
| **MPL 2.0** | ✅ Volně | Změny v MPL souborech → open-source |
| **LGPL** | ✅ (dynamic link) | Statický link = tvůj kód musí být LGPL |
| **GPL v2/v3** | ⚠️ Podmínečně | Tvůj kód musí být GPL (copyleft) |
| **AGPL** | ❌ Rizikové | Network use = distribuce. SaaS musí open-source |
| **SSPL** | ❌ Trap | Self-host = celá platforma musí být open |
| **BSL** | ⚠️ Dočasné | Po conversion date (1–4 roky) → open |
| **Proprietary** | ❌ | Placená licence nutná |
| **Custom** | ❓ | Čti celý LICENSE.md |

**Případ mapcn**: MIT ✅, ale CARTO basemap (separate ToS) = komerční → Enterprise licence nebo swap basemap.

```bash
# Přečti celý LICENSE
gh api repos/OWNER/REPO/license | jq -r '.content' | base64 -d

# Hledej komerční restrikce i mimo LICENSE (README, docs)
gh api repos/OWNER/REPO/readme | jq -r '.content' | base64 -d \
  | grep -i -A3 "commercial\|enterprise\|license\|paid"
```

---

## 5. Kód kvalita (spot check)

```bash
# Existují testy?
gh api repos/OWNER/REPO/contents | jq '.[].name' | grep -iE "test|spec|__tests__"

# TypeScript?
gh repo view OWNER/REPO --json primaryLanguage | jq '.primaryLanguage.name'

# package.json — deps audit
gh api repos/OWNER/REPO/contents/package.json \
  | jq -r '.content' | base64 -d | jq '.dependencies, .devDependencies'

# CI/CD setup?
gh api repos/OWNER/REPO/contents/.github | jq '.[].name' 2>/dev/null

# CHANGELOG existuje?
gh api repos/OWNER/REPO/contents | jq '.[].name' | grep -i changelog
```

---

## 6. Alternativy srovnání (context7 pattern)

Před rozhodnutím vždy porovnej:
```
1. Tato library
2. Nejbližší alternativa (hledat: "CATEGORY site:github.com stars:>1000")
3. Hand-rolled řešení (odhad složitosti)
```

Příklad pro mapy:
| Library | Stars | Licence | Basemap | Bundle |
|---|---|---|---|---|
| mapcn | 7K | MIT* | CARTO ($$) | ~500KB |
| react-map-gl | 8K | MIT | Mapbox ($) | ~400KB |
| leaflet + react-leaflet | 40K | BSD | OSM (free) | ~150KB |
| deck.gl | 12K | MIT | Any | ~800KB |

*CARTO basemap má vlastní ToS

---

## 7. Závěrečné skóre

Po analýze vygeneruj:

```
REPO: owner/repo
SKÓRE: X/10

✅ Pros:
- ...

⚠️ Rizika:
- ...

❌ Red flags:
- ...

VERDIKT: [ADOPT / TRIAL / AVOID]
Důvod: 1 věta
Komerční use: [OK / PODMÍNEČNĚ / NE]
```

---

## Quick one-liner pro celkový přehled

```bash
REPO="owner/repo"
gh repo view $REPO --json name,description,stargazerCount,forkCount,\
createdAt,pushedAt,primaryLanguage,licenseInfo,isArchived \
| jq '{
  name: .name,
  desc: .description,
  stars: .stargazerCount,
  forks: .forkCount,
  fork_ratio: (.forkCount / .stargazerCount * 100 | round | tostring + "%"),
  lang: .primaryLanguage.name,
  license: .licenseInfo.key,
  last_push: .pushedAt,
  archived: .isArchived
}'
```
