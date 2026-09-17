# ClinicPilot Research Portal

Welcome to the **ClinicPilot Research & Practice Intelligence Portal**. This repository contains competitive benchmarking, clinical ergonomic studies, feature scoring frameworks, market sizing models, and raw historical archives guiding the architecture and evolution of ClinicPilot.

---

## Table of Contents
1. [Core Research Documents](#1-core-research-documents)
2. [Research Methodology & Field Evidence](#2-research-methodology--field-evidence)
3. [Key Strategic Insights](#3-key-strategic-insights)
4. [Raw Archives & Historical Record](#4-raw-archives--historical-record)

---

## 1. Core Research Documents

| Document | Primary Focus | Key Takeaways |
|---|---|---|
| [**Competitive Analysis & Benchmark**](competitive-analysis.md) | In-depth audit of open-source engines (OpenEMR, Frappe Health, Medplum) and commercial tools (Practo, Cliniko, Hompath, RadarOpus, Vyapar). | Establishes the KEEP / IMPROVE / COMBINE / INNOVATE / DEFER / REJECT matrix and details ClinicPilot's offline-first solo-doctor advantage. |
| [**Feature Matrix & Pragmatic Roadmap**](feature-matrix.md) | Scoring candidates A through K on clinical impact, engineering effort, and operational risk. | Distinguishes between practice-growth tools (retention, recall, review velocity) and bureaucratic administrative bloat. |
| [**Product Opportunity & Monetization**](product-opportunity.md) | Market sizing across 325k+ homeopaths in India, zero-cost Google Drive cloud backup, and ethical freemium economics. | Lays out the ₹125/month value equation, doctor acquisition channels, and modular multi-specialty expansion. |
| [**Clinical UX & Ergonomic Analysis**](ux-analysis.md) | Exhaustive UX research for the high-intensity Outpatient Department (OPD) environment. | 48dp touch targets, thumb-zone mechanics, harsh clinic lighting contrast, low-cognitive-load posology pads, and error prevention. |

---

## 2. Research Methodology & Field Evidence

Our product decisions are grounded in direct empirical observation of medical practice rather than theoretical software assumptions:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CLINICAL RESEARCH METHODOLOGIES                      │
├──────────────────────────────┬─────────────────────────────────────────┤
│ 1. In-Situ OPD Shadowing     │ Observing solo clinicians during peak   │
│                              │ evening rush (6:30–9:30 PM). Measuring  │
│                              │ time-per-tap and physical distractions. │
├──────────────────────────────┼─────────────────────────────────────────┤
│ 2. Dual-Tasking Analysis     │ Evaluating UI usability when the doctor │
│                              │ holds a phone in one hand while using a │
│                              │ stethoscope or palpating with the other.│
├──────────────────────────────┼─────────────────────────────────────────┤
│ 3. Practice Retention Audits │ Analyzing historical consultation logs  │
│                              │ to uncover true clinic bottlenecks      │
│                              │ (acquisition & drop-off vs. paperwork). │
├──────────────────────────────┼─────────────────────────────────────────┤
│ 4. Stress & Lighting Testing │ Validating typography and color schemes │
│                              │ under harsh fluorescent tubes, outdoor  │
│                              │ rural camps, and dim examination rooms. │
└──────────────────────────────┴─────────────────────────────────────────┘
```

---

## 3. Key Strategic Insights

1. **The Solo Clinician Works Under Cognitive Strain**:
   A solo practitioner operates without administrative assistants or receptionists. Any digital interaction requiring more than 2–3 taps per patient is abandoned during active clinic hours.
2. **Growth Precedes Administration**:
   A struggling solo clinic does not fail due to a lack of complex EHR forms; it fails because patients do not return for follow-ups. Tools that automate recall, capture Google reviews, and compute marketing ROI create immediate practice viability.
3. **Data Sovereignty is an Unbeatable Moat**:
   Physicians are deeply skeptical of centralized cloud platforms that commercialize patient lists. Storing data 100% locally with on-device AES-256 encryption guarantees absolute compliance under India's Digital Personal Data Protection (DPDP) Act and builds enduring clinician trust.
4. **Zero-Cost User-Owned Cloud Sync**:
   Delegating automated encrypted backups to the doctor's personal Google Drive (`drive.appdata`) eliminates ongoing developer server costs while resolving the doctor's fear of device loss.

---

## 4. Raw Archives & Historical Record

To preserve institutional memory and engineering decisions, unedited background research and evolution prompts are archived in the `_raw/` directory:

- [**Doubts & Strategic FAQs**](_raw/doubts-and-faq.md): Comprehensive compilation of early technical inquiries, APK sizing calculations (Flutter C++ engine vs. native tools), ProGuard/R8 safety ratings, anti-tamper mod defense layers, and monetization ethics.
- [**Legacy Prompts & Engineering Directives**](_raw/legacy-prompts/):
  - `ANTIGRAVITY_PROMPT_v0.1.1_v0.2.md`
  - `ANTIGRAVITY_PROMPT_v0.3_UPDATES.md`
  - `ANTIGRAVITY_PROMPT_v0.4_DESIGN.md`
  - `ANTIGRAVITY_FIXES_ROUND2.md`
  - `ANTIGRAVITY_FIXES_UI_ROUND3.md`
  - `CLINICPILOT_MASTER_PROMPT.md`
