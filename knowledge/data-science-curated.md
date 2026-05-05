# Data Science — OneFlow-Curated Reference

> Source: [academic/awesome-datascience](https://github.com/academic/awesome-datascience) (~30k★, MIT)
> Cherry-picked 2026-04-30 z 1264-řádkového repa. **Subset** zaměřený na OneFlow use cases: DD/finance, scraping/enrichment, NLP cold email/IG, viz/dashboards, time-series, MLOps. ~70% původního repa skip (university courses, beginner tutorials, hobby).
> Komplementární k: `~/.claude/skills/data-analysis/SKILL.md` (Excel/CSV analysis), `~/.claude/expertise/data-enrichment.yaml` (ARES/Apollo/Hunter), `~/.claude/skills/dd-batch-sql/` (DuckDB/SQLite RAG), `~/.claude/knowledge/expertise-ai-ml.md`, `~/.claude/knowledge/expertise-finance.md`.

---

## Use-Case Routing (OneFlow → tool/lib)

| OneFlow task | Primary tool | Why |
|---|---|---|
| DD risk scoring (DSCR/LTV/A-F grade pro emitent) | **SHAP + LightGBM** | explainable feature contributions na nuancové DD |
| Batch DD 50+ emitentů (existující `/dd-batch-sql`) | **DuckDB + Polars + Statsmodels** | DuckDB je v ekosystému, Polars >Pandas pro 10k+ rows, Statsmodels = hypothesis testing |
| Time-series default rate, cash flow trendy | **statsmodels + Prophet** | classical forecasting, není potřeba DL pro CZ emitenty (sub-100 sample size) |
| Anomaly detection (fraud signals, weird emitent patterns) | **Isolation Forest (sklearn) / Chaos Genius** | unsupervised, no labels needed |
| Cold email reply classification (positive/negative/spam) | **spaCy + scikit-learn LogisticRegression** | CZ NLP works, lightweight, no GPU |
| IG analyzer hook clustering | **HDBSCAN + sentence-transformers** | density-based + multilingual embeddings |
| Tereza pipeline scoring (1917 podnikatelů) | **scikit-learn ensemble (RF + LGBM)** | tabular features, interpretable |
| Scraping engine v4 ETL (10067 firem) | **Polars + Apache Airflow nebo Prefect** | Polars rychlost, Airflow orchestration (alternativa Filipova Conductoru) |
| Viz pro DD reports / investor dashboards | **Plotly + Streamlit** | interactive web reports, embeddable v PDF |
| Quick exploratory analysis | **Disco** | superhuman EDA, najde subgroup effects co manual missuje, p-values + literature citations |
| Chat-with-database pro OneFlow CRM | **AI for Database** | NL → SQL, instant insights bez learn SQL |
| Hyperparameter tuning na DD model | **Optuna** | best Bayesian opt, no GPU needed |
| Web scraping with markdown output | **Frostbyte MCP** | 13 data tools v MCP, including web scrape→md |
| Probabilistic finance modeling | **PyMC3 nebo PyStan** | Bayesian DSCR confidence intervals |
| MLOps pokud OneFlow ML škáluje | **MLflow + DVC + Weights&Biases** | open-source, free tier dostatečný |

---

## Top Python Libraries (OneFlow stack mapping)

### Tier 1 — Pravděpodobně už používáš nebo MUSÍŠ
- **[Pandas](https://pandas.pydata.org/)** — DataFrame standard
- **[NumPy](https://numpy.org/)** — numerical foundation
- **[scikit-learn](https://scikit-learn.org/)** — classical ML, ensemble, preprocessing
- **[Polars](https://github.com/pola-rs/polars)** — Rust-backed Pandas alternativa, **3-30× faster** pro 10k+ rows. Použij pro Tereza 1917, scraping 10k+, batch DD.
- **[DuckDB](https://github.com/duckdb/duckdb)** — in-process SQL OLAP. Už v `/dd-batch-sql`. Skvělé pro local analytics bez DB serveru.
- **[Plotly](https://plotly.com/python/)** — interactive viz pro DD reports
- **[Streamlit](https://github.com/streamlit/streamlit)** — rapid ML/data app prototype, embedovatelné do OneFlow Nabídky

### Tier 2 — Když konkrétní task volá
- **[XGBoost](https://github.com/dmlc/xgboost)** — tabular ML champion
- **[LightGBM](https://github.com/microsoft/LightGBM)** — faster než XGBoost, lepší pro <50k rows (Filip's typical scale)
- **[CatBoost](https://github.com/catboost/catboost)** — categorical features without one-hot
- **[SHAP](https://github.com/slundberg/shap)** — explainable ML, **POVINNÉ pro DD models** (proč Claude říká RED na emitenta)
- **[LIME](https://github.com/marcotcr/lime)** — local explanations
- **[Optuna](https://github.com/optuna/optuna)** — hyperparameter optimization
- **[Statsmodels](https://www.statsmodels.org/)** — inferential statistics, hypothesis testing, time series
- **[PyMC3](https://docs.pymc.io/)** / **[PyStan](https://pypi.org/project/pystan/)** — Bayesian inference, confidence intervals na DSCR/LTV
- **[Featuretools](https://github.com/alteryx/featuretools)** — automated feature engineering
- **[skrub](https://github.com/skrub-data/skrub/)** — tabular preprocessing

### Tier 3 — Specializované
- **[spaCy](https://spacy.io/)** — performant NLP, CZ dostupný (`cs_core_news_lg`)
- **[Gensim](https://radimrehurek.com/gensim/)** — topic modeling, word2vec
- **[NLTK](https://www.nltk.org/)** — basic NLP toolkit
- **[Hugging Face transformers](https://huggingface.co/)** — pre-trained modely (use sparingly, GPU heavy)
- **[Vaex](https://vaex.io/)** — bigger-than-RAM datasets (100M+ rows)
- **[Dask](https://dask.org/)** — distributed Pandas pokud Polars nestačí
- **[cleanlab](https://github.com/cleanlab/cleanlab)** — automatic dataset issue detection
- **[hmmlearn](https://pypi.org/project/hmmlearn/)** — Hidden Markov Models pro sekvence

### Tier 4 — Deep Learning (nepoužívat default, jen když opravdu třeba)
- **[PyTorch](https://github.com/pytorch/pytorch)** — DL framework, default
- **[TensorFlow / Keras](https://www.tensorflow.org/)** — alternativa, lepší pro production deployment
- **[JAX](https://github.com/google/jax)** — research-grade

> **Pro 99 % OneFlow problémů NEPOUŽÍVAT DL.** CZ emitenti = 5-50 records, DL vyžaduje 1000+. LightGBM porazí DL na tabular data pod 100k rows téměř vždy.

---

## Visualization (OneFlow brand-aware)

| Tool | Use case | OneFlow brand fit |
|---|---|---|
| **[Plotly](https://plotly.com/python/)** | interactive web charts, DD reports | ✅ custom theme s mono palette |
| **[Streamlit](https://streamlit.io/)** | rapid dashboard, internal tooling | ✅ theme.toml s OneFlow brand |
| **[altair](https://altair-viz.github.io/)** | grammar-of-graphics, declarative | ✅ Vega-Lite themable |
| **[bokeh](https://bokeh.org/)** | interactive web viz | ⚠️ default styling neutral |
| **[D3.js](https://d3js.org/)** | custom web viz, ne-Python | ✅ already in site-builder skill |
| **[Datawrapper](https://www.datawrapper.de/)** | journalism-quality charts | ⚠️ SaaS, free tier limited |
| **[teeplot](https://github.com/mmore500/teeplot)** | auto-organize viz output | ✅ workflow tool |

**Anti-pattern:** matplotlib bez custom theme. Default = horrible looking. Vždy `plt.style.use('seaborn-v0_8-whitegrid')` nebo plotly s OneFlow brand.

---

## Visualization Tools (browser-side, ne-Python)

- [amCharts](https://www.amcharts.com/), [AnyChart](https://www.anychart.com/), [Bokeh](https://bokeh.org/), [Highcharts equivalents]
- [Apache Superset](https://superset.apache.org/) — open-source BI dashboard (alternative k Metabase)
- [Cube](https://square.github.io/cube/) — semantic layer pro analytics

---

## Datasets (relevant pro OneFlow research)

### Finance & Economic
- **[NASDAQ:DATA](https://data.nasdaq.com/)** — premier financial datasets (paid tier expensive, free tier limited)
- **[St. Louis FRED](https://fred.stlouisfed.org/)** — Federal Reserve economic data, free, CZ benchmarks via OECD
- **[FinancialData.Net](https://financialdata.net/documentation)** — stock market, financial statements, sustainability data
- **[World Bank Data](https://data.worldbank.org/)** — global economic indicators
- **[European data portal](https://data.europa.eu/en)** — EU public data, includes CZ
- **[Helium](https://heliumtrades.com/mcp-page/)** — real-time news + financial data + ML options pricing, MCP server

### General research / context
- **[Hugging Face Datasets](https://huggingface.co/datasets)** — ML training data
- **[Kaggle Datasets](https://www.kaggle.com/datasets)** — competition + community
- **[Google Dataset Search](https://datasetsearch.research.google.com/)** — meta-search
- **[Academic Torrents](https://academictorrents.com/)** — research data archive

### Czech-specific (mimo awesome-ds)
- **[ČSÚ](https://www.czso.cz/)** — Czech Statistical Office (NOT v awesome-ds, ale POVINNÉ pro CZ market intel)
- **[ARES](https://ares.gov.cz/)** — business registry, už máme v `expertise/data-enrichment.yaml`
- **[ISIR](https://isir.justice.cz/)** — insolvence registry, už máme v DD pipeline

> **CZ datasets gap:** awesome-ds má 80+ datasets ale ZERO CZ-specific. Pro OneFlow critical: ČSÚ + ČNB + ARES + ISIR + Cuzk-RUIAN. Tyto NEjsou v awesome-ds — máme custom v `expertise/data-enrichment.yaml`.

---

## MLOps Stack (pokud OneFlow scaling, free-tier first)

| Layer | Tool | Cost | Why this |
|---|---|---|---|
| Experiment tracking | **MLflow** | OSS, self-host | versioning models + params + metrics |
| Data versioning | **DVC** | OSS, self-host | git-like na large datasets, integruje s S3/GCS |
| Model serving | **Streamlit Cloud** | free tier | rapid demo bez infra |
| Workflow orchestration | **Prefect** nebo **Apache Airflow** | OSS | alternativy k Filipova Conductoru |
| Hyperparameter tuning | **Optuna** | OSS | Bayesian, lepší než grid search |
| Production monitoring | **Arize-Phoenix** | OSS local, paid SaaS | drift detection, latency tracking |
| Feature store | **Feast** | OSS | reusable features across models |
| Cleanup / lineage | **LineaPy** | OSS | Jupyter notebook → production pipeline |

**Filip's reality check:** OneFlow má <10 ML models. Většina = DD risk scoring + lead scoring. **MLflow + DVC stačí.** Skip rest until potřeba dokázána.

---

## NLP (cold email + IG + brand voice)

### CZ NLP stack (Filip-tested)
- **[spaCy](https://spacy.io/)** + `cs_core_news_lg` — POS tagging, NER, lemmatization in CZ
- **[Hugging Face](https://huggingface.co/)** — `Seznam/small-e-czech` (CZ embeddings), `UWB-AIR/Czert-B-base-cased`
- **[Sentence-Transformers](https://www.sbert.net/)** — multilingual embeddings (LaBSE supports CZ)

### Existing OneFlow integration
- Cold email scoring (deliverability + sentiment) → already v `expertise/email-deliverability.yaml`
- IG analyzer (hook patterns) → `/instagram-analyzer` skill
- Brand voice check → `oneflow-brand-voice-check` (OpenSpace skill)

### Net-new opportunities
- **Reply classification model** (positive intent / negative / neutral / spam) na cold email replies — train na 100+ historických replies, sklearn LogisticRegression + spaCy embeddings = 80%+ accuracy, 0 GPU
- **Hook clustering** na IG analyzer výstupy — HDBSCAN nad sentence-transformer embeddings → identify viral patterns
- **Email subject line A/B optimizer** — UCB bandit nad subject lines + open rates from Postfix logs

---

## Agents & MCP Tools (compatible s ekosystémem)

### MCP servery k zvážení (verify pricing first!)
- **[Frostbyte MCP](https://github.com/OzorOwn/frostbyte-mcp)** — 13 data tools (web scrape→md, IP geo, DNS, code exec, screenshots). One API key for 40+ services. **VERIFY pricing — claim "free tier" not confirmed**.
- **[BGPT MCP](https://bgpt.pro/mcp)** — scientific papers DB, structured fields per paper. Pro DD research na nove sektory.
- **[Helium MCP](https://heliumtrades.com/mcp-page/)** — real-time financial data, options pricing. Pro emitent benchmarking.

### Already in Filip's stack
- `mcp__obsidian-oneflow-vault__*` — vault search/CRUD
- `mcp__memory-search__*` — semantic memory
- `mcp__github__*` — repo operations
- `mcp__notebooklm-mcp__*` — research via NotebookLM (zero-cost)
- `mcp__chrome-devtools__*` — browser automation

---

## Beginner Roadmap (skip — Filip má foundations)

awesome-ds doporučuje:
1. Python basics → ✅ Filip má
2. Pandas/NumPy/Matplotlib/Scikit-Learn → ✅ Filip má
3. Beginner projects (Titanic, house price) → ❌ skip, Filip má real OneFlow data
4. Math basics (Stats/LinAlg/Prob) → ⚠️ refresh zone, ale ne primary
5. Supervised → Unsupervised → DL → ⚠️ skip DL, useless pro <100k rows

**Filip-specific learning gaps:**
- Bayesian inference (PyMC3) — pro confidence-aware DD recommendations
- Survival analysis (`scikit-survival`) — pro emitent default time-to-event modeling
- Causal inference (`causalml` from Uber) — co kdyby Filip změnil pricing?
- Time series at scale (statsmodels VAR, Prophet) — pro market regime detection

---

## Other Awesome Lists (downstream loading triggers)

Až bude konkrétní deeper dive potřeba:
- [Awesome Machine Learning](https://github.com/josephmisiti/awesome-machine-learning) — language-segmented ML libs
- [Awesome Public Datasets](https://github.com/awesomedata/awesome-public-datasets) — biggest dataset list
- [Awesome Fraud Detection Papers](https://github.com/benedekrozemberczki/awesome-fraud-detection-papers) — relevant pro OneFlow DD anomaly
- [Awesome Gradient Boosting Papers](https://github.com/benedekrozemberczki/awesome-gradient-boosting-papers) — XGBoost/LGBM theory
- [Awesome Decision Tree Papers](https://github.com/benedekrozemberczki/awesome-decision-tree-papers) — tree-based ML
- [Awesome Community Detection](https://github.com/benedekrozemberczki/awesome-community-detection) — pro graphiti / KG analýzu
- [Awesome Data Analysis](https://github.com/PavelGrigoryevDS/awesome-data-analysis) — meta-list

**Loading rule:** Tyto NEnačítej speculativně. Trigger = explicit task ("fraud detection na emise XYZ" → load awesome-fraud-detection-papers).

---

## Cross-Links na existing OneFlow projects

| Projekt | Aplikace tools |
|---|---|
| `project_scraping_engine.md` (10067 firem) | Polars > Pandas, DuckDB pro analytics, Featuretools pro auto-FE |
| `dd-emitent` skill / `dd-batch-sql` | LightGBM + SHAP + Optuna + Statsmodels |
| `dd-pipeline` | PDF extraction (pdfplumber, už máme) + spaCy NER + LightGBM |
| `project_tereza_complete_2026_04_28.md` (1917 podnikatelů) | Polars + scikit-learn ensemble, sentence-transformers pro web content scoring |
| `project_ig_analyzer` | HDBSCAN clustering, OpenAI Whisper (already in stack) + sentence-transformers |
| `cold_email_setup.md` | spaCy CZ + sklearn LogisticRegression, A/B test design (`/ab-test-design`) |
| `project_oneflow_meta_ads.md` | UCB bandit nad creative variants, statsmodels confidence intervals |
| `project_komunikace_sync.md` | NLP topic modeling (Gensim) → daily digest auto-categorization |

---

## Anti-Patterns (NEDĚLAT)

❌ **Auto-install tools z curated listu** — read first, evaluate against existing, install pouze pokud filip explicit nebo task vyžaduje
❌ **Default deep learning** — pro <100k rows = LightGBM/XGBoost vyhraje
❌ **Ignorovat existing /data-analysis a /dd-batch-sql** — jsou production-ready, neduplikuj
❌ **Pandas na 100k+ rows** — Polars je 3-30× rychlejší, drop-in
❌ **MLflow setup pre tutorial scale** — overkill pro <10 modelů
❌ **Native US datasets pro CZ analýzu** — vždy CZ-first (ČSÚ/ČNB/ARES), US benchmark druhotně
❌ **Generic awesome-ds tutorials** — Filip skip foundational, jdi rovnou na advanced (Bayesian, causal, survival)

---

## When to load this file

| Filip phrase / task | Load? |
|---|---|
| "DD risk model", "emitent scoring", "DSCR confidence interval" | ✅ ANO + `expertise-finance.yaml` |
| "scraping 10k+", "ETL pipeline", "Polars vs Pandas" | ✅ ANO + `expertise/data-enrichment.yaml` |
| "NLP analýza CZ textů", "sentiment cold email", "topic modeling" | ✅ ANO + `expertise/email-deliverability.yaml` |
| "anomaly detection", "fraud signals", "outlier emitent" | ✅ ANO + `expertise/czech-regulatory.yaml` |
| "viz dashboard", "interactive chart", "Plotly streamlit" | ✅ ANO |
| "MLOps", "model versioning", "MLflow setup" | ✅ ANO |
| "Bayesian", "PyMC", "probabilistic modeling" | ✅ ANO |
| "machine learning interview", "courses to learn DS" | ❌ NE (skip — Filip má foundations) |
| "deep learning na 50 emitentů" | ⚠️ READ + redirect na LightGBM |
| Triviální ops (grep, ls, read) | ❌ NE |

---

## Reference

- **Source:** [academic/awesome-datascience](https://github.com/academic/awesome-datascience) (MIT, ~30k★, 1264 lines)
- **Curated:** 2026-04-30 by Filip's ekosystém integration
- **Existing complement:** `~/.claude/skills/data-analysis/`, `~/.claude/expertise/data-enrichment.yaml`, `~/.claude/skills/dd-batch-sql/`, `~/.claude/knowledge/expertise-ai-ml.md`, `~/.claude/knowledge/expertise-finance.md`
- **Obsidian MOC:** `~/Documents/OneFlow-Vault/05-Knowledge/Data-Science-Hub.md`
- **Memory:** `project_data_science_integration_2026_04_30.md`
- **Loading triggers:** see `~/.claude/rules/knowledge-router.md` § Data Science
