# Prompt to send to your peer

Copy-paste this whole block into a chat / DM / email to anyone who runs their own Claude Code setup. It's self-contained — they don't need any prior context from you.

---

## START COPY HERE ──────────────────────────────────────────────

Hey — I just published my Claude Code ecosystem (rules, skills, expertise, hooks) as a public repo so we can cherry-pick from each other instead of independently re-inventing the same wheels. Reciprocity-style: I share mine, you share yours, both of us upgrade.

**My repos**:
- Full ecosystem: https://github.com/filipdopita-tech/claude-ecosystem-setup
- Mythos skill (standalone): https://github.com/filipdopita-tech/mythos-skill

**The ask**: mirror your `~/.claude/` (rules + skills + expertise + hooks) to a public repo, sanitize, and send me the link. Then we both browse + cherry-pick.

**What I'd love to steal from you specifically**:
- Domain expertise YAMLs for fields I don't touch (yours)
- Skills wrapping APIs/services I haven't integrated
- Behavioral rules that solved problems I haven't hit yet
- Hooks for edge cases I'm not catching

**To make sanitization fast** — see `COLLABORATION.md` in my repo for the exact patterns. Hard blockers:
- API keys, tokens, secrets → must be excluded
- Personal credentials, customer data → must be removed
- Auto-memory directory (`projects/`) → gitignored

Soft replace with placeholders: name → `[YOUR_NAME]`, company → `[YOUR_COMPANY]`, IPs → `REDACTED_VPN_IP`, etc. There's a sanitization script you can adapt in my repo's commit history.

**Run this once before pushing** — checks for common leaks:

```bash
cd ~/your-eco-repo
for p in "API_KEY" "Bearer " "BEGIN PRIVATE" "BEGIN OPENSSH" "AKIA" "ghp_" "sk-ant-" "xoxb-"; do
  hits=$(grep -ril "$p" . 2>/dev/null | grep -v "\.git/")
  [ -n "$hits" ] && echo "⚠ LEAK: $p in $hits"
done
echo "✓ Scan done"
```

If `gitleaks` is installed (`brew install gitleaks`), this is even simpler:
```bash
gitleaks detect --source . --verbose
```

**Once you push**, drop the link in a DM or open an issue on my repo. I'll browse, cherry-pick, and add your repo to the "Peer Ecosystems" table so the next collaborator can find you too.

If you want to skip the whole publish step and just send me a tar of your `~/.claude/` privately, that works too — but the network gets stronger when it's public, so push if you can.

— [Sender's name / signature]

## END COPY HERE ────────────────────────────────────────────────

---

## Sender notes (don't forward — these are for you)

**Customize before sending**:
- Replace the `— [Sender's name / signature]` line with your actual sign-off
- If you're sending to someone in a specific domain (legal, ML, gaming, etc.), add a sentence calling out *that specific domain* in the "what I'd love to steal" list — makes it concrete instead of generic
- If you have a deadline or context (e.g. "I'm rebuilding my onboarding next week"), say so — gives them a reason to act now vs. later

**Channel suggestions**:
- Engineer-friend with their own setup → DM works
- Twitter/X / LinkedIn post for broader reach → strip the "Hey —" intro and add a CTA at the end
- Mailing list / newsletter → keep the full version, leads with the value (mutual upgrade) not the ask
- Conference / Discord / Slack community → pin or thread it — works as a recurring resource

**Follow-up cadence**:
- 7 days no response → soft poke ("any thoughts on the eco-share idea?")
- 14 days no response → assume not interested, move to next peer
- If they share their repo → reply within 48h with **specific** things you cherry-picked. That signal ("I actually used X from your repo") is what makes them invested in maintaining it.
