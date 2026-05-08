# Privacy Filter — `message-sanitizer.py` upgrade candidate

OpenAI Privacy Filter (Apache 2.0, 1.5B params / 50M active, 128k context) — bidirectional token-classification model pro PII detection.

## Current state vs upgrade

**Current** (`~/scripts/automation/message-sanitizer.py`):
- Regex-based detection (14 patterns: emails, phones, credit cards, IBAN, RČ, etc.)
- 4-tier policy (BLOCK/REDACT/HASH/PASS)
- Fast, deterministic, BUT misses contextual PII (e.g. "Adam Černý from Praha 5" — names ne v dictionary)
- ruflo Pattern 1 implementation

**Upgrade s OpenAI Privacy Filter**:
- ML token classification — context-aware
- 8 output categories (vs 14 regex)
- 128k context window — celý cold email/klient deliverable v jednom passu
- Tunable precision/recall via operating points
- Long Czech text handling (since multilingual via gpt-oss base)
- Drawback: 1.5B params ~3GB download, GPU recommended (CPU fallback exists)

## Install gate (Filip 1-min decision)

```bash
# Local install (downloads ~3GB checkpoint na first run)
mkdir -p ~/.opf
pip install -e ~/Desktop/Codex/external-mirrors/privacy-filter  # po cloning repo
opf --device cpu "Alice was born on 1990-01-02."  # smoke test
```

NEINSTALOVÁNO yet. Trigger pro install:
- Filip explicit "nainstaluj privacy-filter"
- NEBO `message-sanitizer.py` regex falsche-positive/negative incident
- NEBO klient deliverable s GDPR-sensitive obsahem (ČNB compliance)

## Cost
- 0 Kč (Apache 2.0, self-host)
- ~3GB disk
- CPU: ~1-3s per 1k tokens (Mac M1)
- Repo: github.com/openai/privacy-filter (1983★)

## Wire pattern (post-install)

```python
# In message-sanitizer.py — add ML mode flag
if args.mode == "ml":
    from opf import classify_pii
    spans = classify_pii(text)
    for span in spans:
        if span.category in HIGH_RISK_LABELS:
            text = redact_span(text, span)
elif args.mode == "regex":  # default
    text = regex_pipeline(text)  # existing
```

## Reference
- Repo: https://github.com/openai/privacy-filter
- Model card: gpt-oss derivative, 8-category taxonomy
- License: Apache 2.0
