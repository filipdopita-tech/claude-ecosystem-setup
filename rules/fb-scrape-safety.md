# Facebook / Meta Account Safety — HARD RULES

## PRIORITA: Přepisuje autonomy, lean engine, quality-standard, vše ostatní.
Filipův osobní FB účet (c_user `100085841054997`) = infrastruktura pro osobní/business komunikaci. Blokace nebo flagging = reputační a provozní katastrofa. Proto: zero tolerance na akce, které Meta detection pipeline může vyhodnotit jako ATO (account takeover) / scraping / bot.

---

## HARD STOPS (NIKDY, bez explicit verbal svolení Filipa při každém použití)

1. **Žádné headless Playwright / requests logins do reálných Meta účtů** (Filipův nebo cizí) z VPS, DC IP, nebo residential IP.
   - Žádné `storage_state=...` s reálnými cookies v headless prohlížeči
   - Žádné `requests.Session` posting do `mbasic.facebook.com/login/` s reálným heslem
   - Žádné `login_form.fill()` Playwright patterny proti facebook.com

2. **Žádné použití Filipových Safari/Chrome cookies** (`browser_cookie3 -f facebook.com`, extracted `c_user`/`xs`/`datr`) v automatizovaném scraping pipeline.
   - Cookie extrakce pro ad-hoc manuální debug je OK — **cookie v souboru + jeho použití v nohup/systemd/cron scriptu = HARD STOP**

3. **Žádný SOCKS reverse tunnel Mac→VPS pro FB trafic** bez explicit Filipova "ano, pusť to".
   - `ssh -R 1080 ... vps-dev` + Flash outbound přes Mac IP = detection trigger pro "residential→DC hopping" pattern
   - SOCKS pro jiné účely (non-FB) je OK

4. **Žádné scrape Page/Profile pod autentizovanou session** třetí osoby (klientovy, partnera, rodinného příslušníka) i když máme heslo.
   - Meta TOS violation
   - Risk: trigger 2FA storm na cizí telefon, account lock, support ticket
   - Incident precedent: Tereza Tulcová 2026-04-21 — account locked po 2 login attempts

5. **Žádné bulk `c_user` enumerace** přes Graph / mbasic (/profile.php?id=N) s retry loopy.
   - Rate limiting Meta ≠ tvé rate limiting. Tvých 1 req/s = jejich "bot" flag.

6. **Žádné použití Apify / Bright Data / Phantombuster aktorů** pro scraping Filipových friends/followers/inboxes bez přímého Filipova pokynu a cost approvalu.

---

## DETECTION TRIGGERS (okamžitě STOP + eskaluj Filipovi)

Pokud se objeví některý ze signálů → **zastav všechny FB/Meta scripty, purge cookies, kill tunely, report**:

- Push notifikace na Filipově telefonu: "Someone is trying to log in", "New device signed in"
- SMS s 6-digit FB codem, který nikdo nevyžádal
- Email z `security@facebookmail.com` o novém přihlášení
- Checkpoint stránka / "We've suspended your account" / "Please confirm your identity"
- 2FA storm (více než 1 push / 5 minut)
- Facebook začne vyžadovat reCAPTCHA nebo photo ID upload pro normální akce Filipa

Po triggeru → **Emergency Cleanup Protocol** níže.

---

## EMERGENCY CLEANUP PROTOCOL (při detection triggeru)

```bash
# 1. Kill all FB-related processes
ssh vps-dev "pkill -f 'playwright|fb-scrape|fb-login|facebook' || true"
pkill -f 'ssh -R 1080' || true   # SOCKS tunnel

# 2. Purge cookies + states (Flash)
ssh vps-dev "rm -rf /home/claude/fb-scraper/fb_session/* /root/.credentials/*fb*.env /tmp/fb_* 2>/dev/null || true"

# 3. Purge cookies + states (Mac)
rm -rf ~/fb-scraper/fb_session/* ~/.credentials/*fb*.env /tmp/fb_* 2>/dev/null || true

# 4. Report to Filip ASAP
ntfy send "FB SAFETY: Detection trigger fired. Cleanup done. Check account."
```

Po cleanup: **doporuč Filipovi** recovery kroky:
1. Settings → Security and Login → "Where you're logged in" → Log out of all other sessions
2. "Recent account activity" → reject anything unrecognized
3. Enable 2FA via authenticator app (ne SMS — SIM swap risk)
4. Consider password change pokud heslo mohlo uniknout do script/env souboru

---

## SAFE ALTERNATIVES (když user chce FB data)

Když Filip (nebo klient) chce FB data, nabídni V TOMTO POŘADÍ:

### Tier 1 — Zero risk
- **Meta Graph API** s Filipovým vlastním Meta Developer app + user-granted access token (jen pro vlastní Page/data kde je Filip admin)
- **Public-only scraping** bez loginu přes `requests` + `BeautifulSoup`: veřejné posty, Page info, public friend lists (malý subset)
- **CrowdTangle / Meta Business Suite exporty** pro Pages, kde má Filip admin access
- **Pokud user chce data své vlastní Page**, požádat ho o přidání Filipa jako admin/analyst → pak Business Suite export = kompletní následovníky

### Tier 2 — Low risk (explicit Filip approval)
- Apify **public profile scrape** (bez loginu, jen veřejná data) — read-only actors, žádné interakce
- Apify actor s **klientovým vlastním** FB účtem pod jeho explicit OAuth — ne Filipův, ne naše session

### Tier 3 — NEVER
- Filipovy cookies v VPS headless
- Klientovy credentials přihlašované naší automatizací
- Jakýkoli pattern, co "simulates a real user" se session cizí osoby

---

## KDYŽ USER NAVRHUJE NEBEZPEČNÝ PŘÍSTUP

Nečekej na dotaz. Přímo řekni:

> "Tohle má risk blokace účtu — použití [tvůj/klientův] Safari session v headless pipeline je Meta detection trigger (2026-04-21 precedent: 2FA storm + account lock na Tereze). Udělám to Tier 1 / Tier 2 cestou: [konkrétní alternativa]."

Nikdy nepokračuj jen proto, že "user řekl ok" — musí být přímý verbální pokyn pro TENTO konkrétní headless login / cookie injection, ne obecné "dokonči to" nebo "vyřeš to".

---

## INCIDENT LOG

### 2026-04-21 Tereza Tulcová scrape
- **Co se stalo:** Scrape 897 followers přes Safari cookies (Filipův c_user) + SOCKS tunel Mac→Flash + headless Playwright na facebook.com/profile.php?id=...
- **Trigger:** Filipův telefon začal dostávat "Někdo se snaží přihlásit" push notifikace (FB detection pipeline flagnul session)
- **Risk:** account lock / reputation flag / loss of infrastructure pro Filipův osobní brand
- **Historical miss:** Tereza credentials attempt předchozí = její account locked po 2 login attempts (warning signál, který byl ignorován)
- **Fix:** Emergency cleanup (SOCKS kill, cookie purge Mac+Flash, credentials delete), toto pravidlo zapsáno, recovery doporučeno
- **Rule vznik:** Tento dokument

### Root cause analysis
- Filip explicitně žádal "vše na 100% funkční, všechno na VPS" → agent interpretoval jako "použij session, co je nejefektivnější"
- Chyběl hard rule o cookie + real account + headless combo
- Quality-standard "boil the ocean" a full-autonomy skinu → agent šel do nejefektivnější cesty bez safety check

### Reference
- Memory: `~/.claude/projects/<your-project-id>/memory/feedback_fb_account_safety.md`
- Memory: `~/.claude/projects/<your-project-id>/memory/project_tereza_tulcova_fb_scrape.md`
- Security hardening general: `~/.claude/rules/security-hardening.md`
- Credential handling: `~/.claude/rules/security-hardening.md` (credentials, chmod 600, env files)

---

## VZTAH K OSTATNÍM RULES

- **full-autonomy**: autonomy PLATÍ, ale ne pro akce v této red zone — tenhle rule je explicit HARD-STOP dle feedback_full_autonomy.md pravidla "hard-stop destruktiva/odeslání"
- **quality-standard.md (BtO)**: "permanent fix v dosahu" → v tomto kontextu permanent fix = Tier 1 alternativy, ne hackování přes cookies
- **prompt-completeness.md**: dokončit úkol, ano — ale v bezpečném režimu. Když přístup Tier 1/2 není možný, response JE "Nelze dokončit bez rizika blokace — tady jsou safe alternatives: …"
- **cost-zero-tolerance.md**: Apify read-only public scrape je OK pokud Filip schválí cost. Žádné paid Meta ads API.

---

## TL;DR (pro rychlé načtení)

```
FB scraping = HARD RULE:
  ❌ Headless login do reálného účtu (Filip/klient/třetí osoba)
  ❌ Použití Filipových Safari cookies v automatizaci
  ❌ SOCKS Mac→VPS pro FB traffic
  ❌ Apify login-based scraping
  ✓  Meta Graph API s vlastním dev accountem
  ✓  Public scrape bez loginu (malý scope)
  ✓  Business Suite export když je Filip admin
  ✓  Klientův OAuth consent pro jeho vlastní data

Detection trigger na Filipově telefonu → STOP + cleanup + report.
Žádná akce v této zóně bez explicit verbal Filipova "ano, pusť to" PRO TENTO konkrétní run.
```
