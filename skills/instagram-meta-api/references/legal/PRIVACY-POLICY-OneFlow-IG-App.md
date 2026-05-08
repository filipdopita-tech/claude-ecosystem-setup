# Privacy Policy — OneFlow Instagram Integration

**Effective date:** 2026-05-03
**Last updated:** 2026-05-03
**Controller:** OneFlow s.r.o., Praha, Česká republika

> **Use:** Copy-paste obsah pod čarou níže do Google Docs (File → New → Document) a publish on the web (File → Share → Publish to web → Publish). URL pak vlož do Meta Developer App settings → App Settings → Basic → Privacy Policy URL.

---

## Privacy Policy — OneFlow Instagram Integration

### 1. Who we are

This integration is operated by **OneFlow s.r.o.**, a Czech limited liability company headquartered in Prague, Czech Republic ("we", "us", "our"). For privacy questions contact: **<email>**.

### 2. Scope

This Privacy Policy describes how the **OneFlow Instagram Integration** (the "App") accesses, processes, and stores data obtained from Instagram Business / Creator accounts via the Meta Graph API.

The App is an internal automation tool used by OneFlow s.r.o. to publish content, retrieve insights, and manage direct messages on **its own Instagram Business account(s)**. It is **not a public service** and is not offered to third-party users.

### 3. Data we access

When operated against an Instagram Business or Creator account that has explicitly granted permission, the App may access the following data via Meta Graph API v25.0:

- Account profile information (account ID, username, biography, follower / following counts, media count)
- Pages connected to the account
- Media objects (images, videos, reels, carousels, stories) that have been published or scheduled
- Media insights (impressions, reach, saves, shares, video watch time, retention curves)
- Account-level insights (audience demographics, online activity)
- Direct message conversations and individual messages, including sender/recipient identifiers, timestamps, and message content
- Publishing rate-limit status

### 4. Purpose of processing

We process this data **solely** for the following purposes:

- Publishing OneFlow-owned content to OneFlow-owned Instagram accounts
- Measuring performance of OneFlow-published content (post-publish analytics)
- Responding to direct messages received by OneFlow accounts
- Operating comment-trigger automations on OneFlow-owned content (e.g., automated reply when a follower comments a specific keyword)

We do **not** process data of third parties beyond the minimum necessary to fulfill the publishing or messaging function the user has initiated (e.g., delivering a reply to a user who messaged us first).

### 5. Storage

- Insights and post metadata are stored locally on OneFlow-controlled infrastructure (Mac workstation + dedicated VPS in EU jurisdiction).
- No data is transmitted to third parties beyond Meta itself.
- Direct message content is **not** retained beyond the active session unless explicitly archived by an OneFlow operator for customer-service follow-up.
- Access tokens are stored in encrypted form at rest with file-system permission `chmod 600`, accessible only to the OneFlow operator account.

### 6. Retention

- Published-post insights: indefinitely (business analytics, GDPR Art. 6(1)(f) legitimate interest of the controller).
- DM transcripts: max 90 days unless flagged for ongoing customer-service ticket.
- Access tokens: rotated every 60 days per Meta long-lived token lifetime.

### 7. Sharing

We do **not** sell, rent, or share any data accessed via this App with third parties. The only data flow is between Meta's API and OneFlow's local storage.

We may disclose data if compelled by Czech or EU legal process (court order, regulatory request from ČNB, AML/GDPR investigation).

### 8. Your rights (GDPR)

If you are an EU/EEA data subject (e.g., a follower whose comment was processed by automation), you have the right to:

- Access your personal data we process (Art. 15)
- Request correction of inaccurate data (Art. 16)
- Request erasure ("right to be forgotten") (Art. 17)
- Object to processing based on legitimate interest (Art. 21)
- Lodge a complaint with the Czech Office for Personal Data Protection (Úřad pro ochranu osobních údajů, www.uoou.cz)

To exercise any of these rights, contact **<email>**.

### 9. Meta data deletion

To request deletion of any data this App may have processed about you:

1. Email **<email>** with subject "Meta App Data Deletion — [your IG handle]".
2. We will delete relevant records within 30 days and confirm in writing.
3. Alternatively, revoke the App's access via your Instagram Settings → Apps and Websites → Active → OneFlow Instagram Integration → Remove.

### 10. Security

- Credentials are stored locally with `chmod 600`, never in version control, never in logs.
- Network traffic to Meta endpoints uses TLS 1.2+ enforced.
- The App runs only on OneFlow-controlled hardware behind WireGuard VPN.
- Access tokens are rotated every 60 days.
- Incident response: any suspected token compromise triggers immediate rotation + Meta App Dashboard audit log review.

### 11. Children

The App does **not** knowingly process data of users under 13 years of age. Instagram itself prohibits accounts of users under 13.

### 12. Changes to this Policy

We will update this Policy if Meta API scope changes or our processing practices change. The "Last updated" date at the top reflects the most recent revision. Material changes will be communicated via email to <email> subscribers if applicable.

### 13. Contact

OneFlow s.r.o.
Praha, Česká republika
**<email>**

---

**Generated:** 2026-05-03 by OneFlow Codex
**Source pattern:** Meta Developer App requirements (developers.facebook.com/docs/development/release/app-review)
**Compliance reference:** GDPR (EU 2016/679), zákon č. 110/2019 Sb. o zpracování osobních údajů
