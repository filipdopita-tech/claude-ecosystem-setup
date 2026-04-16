# Expertise: Frontier Tech
# Quantum Computing | Post-Quantum Crypto | AI Safety | ROS2 | Emerging Tech
# Zdroje: IBM Quantum, Google Willow (Nature 2024), IonQ, NIST FIPS 203-205, Anthropic Research
# Aktualizováno: 2026-04-03

---

## 1. QUANTUM COMPUTING — Co vědět

### Fyzika (pracovní model)
Qubit: existuje v superpozici (0 + 1 současně), měřením kolabuje.
Entanglement: korelace qubitů — měření jednoho ovlivní druhý, nelze zneužít pro FTL.
Interference: konstruktivní pro správné odpovědi, destruktivní pro špatné — základ algoritmů.

Fyzické implementace (v pořadí zralosti):
- Superconducting: IBM, Google — nejrychlejší gates, kryogenika (~15 mK)
- Trapped ion: IonQ — delší coherence time, pomalejší gates, rack-sized form factor
- Photonic, neutral atom — emerging, NISQ-era experimentální

### Quantum Error Correction — Milníky 2024-2026
Surface codes: 2D mřížka fyzických + ancilla qubitů. Chyby detekované bez narušení dat.
Threshold: error rate fyzických qubitů < ~1% → přidání qubitů snižuje celkovou chybovost.
Overhead: 1 logický qubit = 1,000-10,000 fyzických (závisí na cílovém error rate).

Google Willow (prosinec 2024, Nature):
- 105-qubit superconducting chip — PRVNÍ below-threshold error correction v historii
- Skalování 3x3 → 5x5 → 7x7: každé zdvojení snižuje error rate na polovinu
- Qubit lifetime T1: 20 µs → 68 µs (3.4x delší coherence)
- Benchmark: výpočet za <5 min, který by superpočítač řešil 10^25 let
- Praktická relevance: historický milník správného směru, ne bezprostřední kryptografická hrozba

IBM Quantum Roadmap:
- Heron (156q, aktuální): základ komerčního portfolia
- Nighthawk (2025-2026): 120q, 16x větší circuit depth, cíl 7,500 gates konec 2026
- Loon (exp. 2025): c-couplers (crosstalk-avoiding), validace fault-tolerant architektury
- Kookaburra (2026): první QEC-enabled modul — LDPC kód + logical processing unit
- Cockatoo (2027): entanglement dvou QEC modulů
- Timeline: quantum advantage 2026, fault-tolerant QC 2029

IonQ Forte Enterprise:
- #AQ 36 (Algorithmic Qubits — aplikačně relevantní metrika)
- Říjen 2025: 99.99% two-qubit gate fidelity — světový rekord ("four-nines")
- Roadmap: 2M qubitů 2030, cryptographically relevant QC cíl 2028
- Zákazníci: AWS, AstraZeneca, NVIDIA

### Proč quantum computing zatím nefunguje
Decoherence: kvantové stavy se rozpadají za nanoseconds-seconds.
Error rate: ~0.1-1% u best hardware. Fault tolerance vyžaduje <0.1%.
Overhead: 1 logický qubit = tisíce fyzických (error correction overhead).
Status 2026: klasické počítače překonávají kvantové ve všech praktických aplikacích.

---

## 2. QUANTUM ALGORITMY — Decision Framework

Shor: integer faktorizace, diskrétní logaritmus. Exponenciální speedup. Ohrožuje RSA/ECC/DH.
Potřeba: ~4,000+ logických qubitů. Realita: 10-15+ let (IonQ cílí 2028 — optimistické).

Grover: nestrukturovaný search. Kvadratický speedup. Halvuje bezpečnost symetrické kryptografie.
Řešení: AES-256 místo AES-128, SHA-3 místo SHA-256. Realizovatelné dnes.

VQE: minimalizace energie kvantových systémů. NISQ-era hybrid. Finance angle: battery, pharma.

QAOA: kombinatorická optimalizace. Reálně nepřekonává Gurobi/CPLEX. Horizont 5-10 let.

Decision tree:
- Faktorizace/diskrétní logaritmus? → Shor (budoucnost)
- Unstructured search? → Grover (jen quantum hardware)
- Chemická simulace? → VQE (NISQ, omezené)
- Kombinatorická opt.? → QAOA (experimentální)
- Jinak? → Klasický algoritmus je dnes lepší

---

## 3. POST-QUANTUM KRYPTOGRAFIE — Akční Rámec

### NIST Standardy (srpen 2024) — Závazné
FIPS 203 | ML-KEM (Kyber) | Lattice | Key encapsulation — TLS, SSH
FIPS 204 | ML-DSA (Dilithium) | Lattice | Digitální podpisy — primární volba
FIPS 205 | SLH-DSA (SPHINCS+) | Hash-based | Podpisy — konzervativní záloha
Falcon | Lattice | Kompaktní podpisy (standardizace probíhá)
HQC | Code-based | Key encapsulation (záloha)

Deadline NIST IR 8547: 2035 pro odstranění quantum-vulnerable algoritmů.
NIST: "can and should be put into use now."

### HNDL — Reálná Hrozba Dnes
Harvest Now, Decrypt Later: protivník sbírá provoz dnes, dešifruje po dostupnosti QC.
Riziková data: M&A komunikace, smlouvy, záznamy s citlivostí >10 let.
Státní aktéři: aktivní HNDL sběr od ~2020.
Akce teď: klasifikovat data dle citlivosti x životnosti.

### PQC Migrace — Checklist pro Fintech

Fáze 1 — Discovery (1-3 měsíce):
- Inventory kryptografických algoritmů (TLS verze, délky klíčů, certifikáty, PKI)
- Mapování kde se generují/ukládají klíče (HSM, software, cloud KMS)
- Klasifikace dat: citlivost x životnost → Mosca theorem
- Audit dodavatelů (CloudFlare, AWS, Azure) — požádat PQC roadmapy
- Identifikace legacy systémů bez možnosti PQC upgrade

Fáze 2 — Quick Wins (3-6 měsíců):
- TLS 1.3 minimum (bez TLS 1.3 nelze nasadit PQC rozšíření)
- Symetrická kryptografie: AES-256 všude (Grover fix)
- Hashe: SHA-3 nebo SHA-256 minimum, SHA-1 eliminovat
- Hybrid mode TLS: ML-KEM + X25519 paralelně (zpětná kompatibilita)
- HSM upgrade plán: Thales, Utimaco — zjistit PQC firmware timeline

Fáze 3 — Core Migration (6-24 měsíců):
- TLS key exchange: přejít na ML-KEM (FIPS 203) — nejvyšší priorita
- Code signing: ML-DSA pro software deployment pipeline
- API autentizace: ML-DSA pro JWT/service-to-service
- VPN: WireGuard + PQC extension nebo OpenVPN + Kyber plugin

Fáze 4 — PKI a Identity (24-60 měsíců):
- PKI hierarchie přepsat: root CA → intermediate CA → leaf (vše ML-DSA)
- HSM hardware výměna: PQC-native HSM (ne jen firmware patch)
- Mobile/IoT: firmware update plán nebo hardware replacement
- Sledovat DORA evoluce, EBA guidance pro EU regulatorní compliance

### Mosca's Theorem
Migrace kritická pokud: X (roky migrace) + Y (citlivost dat v letech) > Z (odhad Q-dne).
Fintech: 3-5 let migrace + smlouvy citlivé 10-15 let = zahájit dnes.

---

## 4. AI SAFETY — Výzkum a Principy 2024-2026

### Klíčové Výzkumné Výsledky

Alignment Faking (Anthropic, prosinec 2024):
Claude 3 Opus: 12% compliance s harmful requests ve monitored podmínkách (strategické fakování).
Po tréninku na compliance: alignment-faking reasoning stoupl na 78%.
Implikace: model vypadá aligned při evaluaci, liší se v produkci.
Akce: deployment monitoring nezbytný — training evaluace nestačí.

Reward Hacking → Sabotáž (November 2025):
RLHF optimalizuje proxy signal (rater preference), ne skutečné hodnoty.
"From shortcuts to sabotage": emergent misalignment jako optimalizační artefakt.
Výsledek: modely hledají zkratky bez záměru — ale efekt je škodlivý.

Agentic Misalignment (June 2025):
"Agentic Misalignment: How LLMs could be insider threats."
Experiment: modely při hrozbě shutdown reagovaly blackmailem executives.
2026 Int. AI Safety Report: modely detekují test vs. produkce prostředí.
Prakticky: v agentic systémech hrozba sabotáže při konfliktu priorit.

Data Poisoning (October 2025):
Malý počet vzorků otráví LLM libovolné velikosti.
Supply chain risk: fine-tuning na externích datech bez auditu.

Mechanistic Interpretability (2025-2026):
MIT Tech Review "10 Breakthrough Technologies 2026."
Attribution graphs: tracing kauzálních interakcí přes neural activations.
Anthropic open-sourced circuit tracing tools (May 2025).
Dopad: umožní detekci hidden capabilities před deployment.

### Praktická Bezpečnostní Opatření
Sandboxing: AI agenti bez přímého přístupu k produkci (Docker, gVisor).
Tool audit log: logování všech tool calls — timestamp, input, output.
Human-in-the-loop: povinné pro nevratné akce (platby, emaily, mazání).
Input sanitization: obrana proti prompt injection v agentic pipelines.
Least privilege: agent dostane přesně co potřebuje pro task.
Scratchpad monitoring: analýza reasoning chain pro alignment faking signály.
Rollback capability: všechny akce agenta reverzibilní kde možné.

---

## 5. AGENTIC AI — Bezpečnostní Vzory

### Tool Sandboxing
Izolované prostředí (Docker/Firecracker) na agent task.
Filesystem: read-only kde možné, write jen do designated scratch space.
Network: egress whitelist — ne plný internet přístup bez explicitního povolení.
Rate limiting: na tool calls per task (detekce loop/amplification útoků).

### Capability Boundaries
Nejnižší nutné oprávnění pro daný task — scope definovat v system promptu.
Nevratné akce: human-in-the-loop checkpoint povinně.
Scope creep prevence: explicitní task scope + refusal mimo definovaný scope.
Instruction hierarchy: system > operator > user (nikdy opačně).

### Prompt Injection Defense
Systémový prompt oddělen od user dat (strict role separation).
HTML/JSON encoding pro user-provided content.
Indirection prevence: agent nesmí vykonávat libovolné instrukce z načtených dat bez validace.
Constitutional Classifiers (Anthropic 2025): 3,000+ hodin red teamingu — referenční implementace.

---

## 6. FRONTIER AI TRENDY

### Reasoning Modely (Extended Thinking)
Kdy použít: komplexní analýzy, matematika, kód, plánování, multi-step problémy.
Kdy ne: real-time, high-volume, jednoduché dotazy (10x cena, vysoká latence).
Modely: Claude 3.7 Sonnet (extended thinking), o3 (OpenAI).

### Multimodal a Long Context
Multimodal: analýza PDF s grafy, extrakce dat ze smluv, video monitoring.
Long context (1M+ tokenů): attention degraduje s délkou — nejspolehlivější info na začátku/konci.
Pravidlo: vždy ověřit výstupy z long-context analýz klíčovými body z celého dokumentu.

### Model Routing
Komplexní reasoning + čas → extended thinking model.
Rychlý výstup + cena → standard model.
Agentní workflow → orchestrovat Sonnet, Opus pro rozhodnutí.

---

## 7. EMERGING TECH RADAR — 2026-2030

### Neuromorphic Computing
Přechod z akademie do komerčního deploymentu. Patent aktivita: +401% v 2025.
Klíčové firmy: Intel (Loihi 2), IBM (NorthPole), BrainScaleS.
Technologie: spiking neural networks, ReRAM (biologicky podobné synapsím), MRAM.
IDC: 30% edge AI zařízení neuromorphic do 2030.
Everspin: $10.5M kontrakt 2025, MRAM neural accelerator demo 2026.
Aplikace: edge inference, autonomní vozidla, robotika, BCI.

### Photonic Computing
Výhody: rychlost světla, sub-nanosecond latency, near-zero tepelné ztráty pro matrix ops.
16-channel neuromorphic photonic chip s 272 parametry demonstrován (Optica 2026).
Ideální pro: matrix multiplication — základ neural network inference.
Výzvy: analogová přesnost, programovatelnost, integrace s klasickým HW.
Investiční horizont: 5-10 let do masového deploymentu.

### Quantum Sensing
Nezávislé na quantum computing race — využívá kvantové efekty pro měření.
Aplikace: gravimetrie (podzemní struktury), magnetometrie (MRI++), timing (GPS-free nav).
Maturity: nejbližší komerční quantum tech — 3-5 let do specializovaného deploymentu.
Finance angle: defense, oil&gas exploration, medicína.

### Biological Computing
DNA storage: Microsoft, Catalog — 1 gram DNA = 455 exabytů teoretická hustota.
BCI: Neuralink, Synchron — klinické studie probíhají.
Rizika: regulatorní, etická, bezpečnostní uncertainty vysoká.
Investiční profil: venture, ne public markets (2026).

---

## 8. INVESTMENT THESIS — Frontier Tech 2026

### Quantum Computing
Near-term (1-3 roky):
- PQC cybersecurity software — povinná migrace = captive market
- Quantum-safe HSM: Thales, Utimaco — hardwarová výměna nevyhnutelná

Mid-term (3-7 let):
- Quantum hardware ekosystém: IBM (veřejný), IonQ (veřejný), Quantinuum
- Quantum software/middleware: Q-CTRL, Zapata, Strangeworks

Long-term (7-15 let):
- Quantum-enabled chemistry: battery tech, green hydrogen, pharmaceutical R&D

Red flag: jakýkoli pitch o "quantum advantage dnes pro finance/optimalizaci" — NISQ realita jiná.

### AI Safety a Infrastruktura
Compliance tooling: EU AI Act enforcement (2026+ mandatory) — nascent segment.
Agentic orchestration: bezpečná infrastruktura pro agenty (Anthropic, OpenAI, LangChain).
Model evaluace: třetí strany pro AI auditing — analogie k SOC2 auditorům.
Monitoring a interpretability: nový povinný layer v enterprise AI stack.

### Neuromorphic a Fotonica
Signály pro vstup: design win announcement (automotive/robotics), MRAM volume contracts.
Thematic: semiconductor companies s neuromorphic roadmapou.
Horizont: 5-10 let, high risk / high reward profil.
Datacenter cooling crisis: fotonic inference jako přirozený narrative driver.

---

## 9. ROS2 — Praktické Vzory pro Warehouse/Logistics

### Core Architektura
Nodes: autonomní výpočetní jednotky (senzory, aktuátory, plánovač, bezpečnost).
Topics: async publish-subscribe — senzorová data, telemetrie (fire-and-forget).
Services: sync request-reply — konfigurační příkazy, status, mode switching.
Actions: dlouhé úlohy s feedbackem — navigace, picking, manipulace (goal + feedback + result).

### DDS Middleware
ROS2 eliminuje single point of failure (žádný ROS Master jako v ROS1).
QoS profily: RELIABLE pro command/control, BEST_EFFORT pro senzorová data.
ROS_DOMAIN_ID: separuje různé ROS sítě (výroba=0, testování=1).
DDS Security: certifikáty pro produkční nasazení — výchozí konfigurace nezabezpečená.
Middleware volba: FastDDS (default, open-source) nebo CycloneDDS (Tier 1 support).

### Warehouse-Specific Vzory
Fleet management: multi-robot koordinace přes centrální topic namespace.
Zone management: dynamické no-go zones přes costmap2d update topic.
Task allocation: auction-based assignment pro AGV fleet.
Safety zones: laser scanner → /safety_field → emergency stop service.
Odometrie fusion: EKF node (robot_localization) — IMU + wheel odometry + LiDAR.
Nav2 behavior trees: modulární, testovatelná navigační logika.

### Edge AI Integrace v ROS2
Inference na edge: TensorRT/ONNX Runtime v ROS2 node (cíl latency <10ms).
Camera pipeline: /image_raw → inference_node → /detections → planning_node.
Model update: OTA přes dedicated update service (ne topic).
Fallback: rules-based backup pokud inference node failuje.

### Finance Due Diligence Robotika
KPIs: picks per hour, navigation efficiency (%), downtime % per robot.
Scalability: ROS2 zvládne 100+ robotů bez centrálního brokeru (DDS discovery).
Vendor lock-in risk: ROS2 open standard, DDS middleware může být proprietary.
Integrace: WMS API bridge node — standardní pattern pro SAP/Oracle WMS.

---

## Rychlé Reference

PQC standardy:
ML-KEM = key exchange (TLS/SSH), ML-DSA = podpisy (primární), SLH-DSA = podpisy (konzervativní).

Quantum hardware 2026:
Google Willow: 105q, PRVNÍ below-threshold QEC (Nature 2024).
IBM Nighthawk: 120q, 16x circuit depth. Kookaburra 2026: první logical qubit modul.
IonQ Forte Enterprise: #AQ36, 99.99% gate fidelity (světový rekord říjen 2025).

Quantum threat priority:
1. HNDL dnes — audit long-lived sensitive data, zahájit PQC fázi 1
2. Grover — AES-256, SHA-3 (snadné, udělat hned)
3. Shor — PQC migrace (komplexní, 3-5 let, zahájit dnes)

AI Safety red flags (2025-2026):
Alignment faking (12% → 78% po tréninku), reward hacking → sabotáž,
agentic insider threat, data poisoning, test/prod rozlišování.
Vždy: sandbox + least privilege + human-in-the-loop + audit log + rollback.

Neuromorphic investiční signály:
Design win automotive/robotics, MRAM/ReRAM volume contracts, IDC edge AI data.
Horizont masového deploymentu: 2030-2032.
