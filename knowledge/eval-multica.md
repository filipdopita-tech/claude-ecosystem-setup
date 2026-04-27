# Eval: multica-ai/multica

Source: multica-ai/multica | MIT (Apache-modified) | brew install multica-ai/tap/multica
Evaluated: 2026-04-15 | Verdict: **NEINSTALOCAT — Paseo/Conductor zůstávají**

## Co to je

Open-source managed agents platform. "Turn coding agents into real teammates."
Dashboard UI kde agentům přiřazuješ issues jako kolegům. Self-hosted nebo cloud.

Kompatibilní s: Claude Code, Codex, OpenClaw, OpenCode.

## Klíčové vlastnosti

- **Agents as Teammates** — profil, board, komentáře, blocker reporty
- **Autonomous Execution** — full task lifecycle (enqueue → claim → start → complete/fail)
- **Reusable Skills** — každé řešení = skill pro celý tým
- **Unified Runtimes** — lokální daemon + cloud, auto-detection CLI
- **Multi-Workspace** — týmová isolace
- **WebSocket streaming** — real-time progress

## Srovnání s Paseo/Conductor (Filip's stack)

| Dimenze | Multica | Paseo/Conductor |
|---|---|---|
| UI | ✅ full dashboard | ❌ CLI + file queue |
| Cost | free (self-host) | $0 (OpenRouter/Gemini free tier) |
| Infra overhead | ⚠️ vyšší (DB, WebSocket server) | ✅ minimal systemd daemons |
| Custom integration | ⚠️ API/webhook based | ✅ přímý Python kód |
| Skill reuse | ✅ formalizovaný | ⚠️ ad hoc via scripts |
| Licence | Apache-modified | N/A (vlastní kód) |

## Proč NEINSTALOCAT

1. **Paseo na 10.77.0.1:6767** je funkční, $0 cost, custom-fit pro OneFlow pipelines
2. **Conductor** je optimalizovaný pro async file-queue model (OneFlow use case)
3. Multica přidává komplexitu (dashboard, DB, WebSocket) bez jasné výhody pro sólový workflow
4. Apache-modified licence: "jen interní use, NE SaaS reselling" — limitující pokud OneFlow bude platformizovat

## Kdy reconsiderovat

- OneFlow najme dalšího dev nebo VA který potřebuje UI task přiřazování
- Paseo/Conductor dosáhne limitu maintainability
- Potřeba formálního agent skill registry (multica reusable skills feature)

## Závěr

Multica je pro AI-native týmy s UI workflow. Filip je sólový, custom stack funguje, přechod by byl YAGNI.
