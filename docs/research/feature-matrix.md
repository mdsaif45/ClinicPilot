# Feature Matrix & Pragmatic Roadmap Analysis

This document preserves and expands the core feature evaluation and pragmatic roadmap analysis for **ClinicPilot**. It evaluates candidate features against the real-world operational constraints of solo clinicians, comparing competitor capabilities against practice-growth priorities.

---

## Table of Contents
1. [The Operational Lens: Real Practice vs. Theoretical Features](#1-the-operational-lens-real-practice-vs-theoretical-features)
2. [Competitor Screen Breakdown vs. ClinicPilot Capabilities](#2-competitor-screen-breakdown-vs-clinicpilot-capabilities)
3. [Comprehensive Candidate Feature Scoring (Impact, Effort, Risk)](#3-comprehensive-candidate-feature-scoring-impact-effort-risk)
   - [Candidate A: Clinic-Wide Follow-Up Recall List](#candidate-a-clinic-wide-follow-up-recall-list)
   - [Candidate B: Payment-Method Collection Breakdown](#candidate-b-payment-method-collection-breakdown)
   - [Candidate C: Google Review Tracker](#candidate-c-google-review-tracker)
   - [Candidate D: Community Camp Manager with Multi-Period ROI](#candidate-d-community-camp-manager-with-multi-period-roi)
   - [Candidate E: Calendar Appointments & Slot Scheduling](#candidate-e-calendar-appointments--slot-scheduling)
   - [Candidate F: Clinical Case Taking, Prescriptions & Media Attachments](#candidate-f-clinical-case-taking-prescriptions--media-attachments)
   - [Candidate G: WhatsApp Deep-Link Quick Actions](#candidate-g-whatsapp-deep-link-quick-actions)
   - [Candidate H: Disease-Specific Revenue & Repeat Analytics](#candidate-h-disease-specific-revenue--repeat-analytics)
   - [Candidate I: Algorithmic Clinic Health Score (0–100)](#candidate-i-algorithmic-clinic-health-score-0100)
   - [Candidate J: Diagnostic Lab & Pharmacy Referral CRM](#candidate-j-diagnostic-lab--pharmacy-referral-crm)
   - [Candidate K: Security Hardening & Encryption at Rest](#candidate-k-security-hardening--encryption-at-rest)
4. [Prioritized Implementation Sequence](#4-prioritized-implementation-sequence)
5. [The Philosophical Distinction: Practice Growth vs. Clinic Administration](#5-the-philosophical-distinction-practice-growth-vs-clinic-administration)
6. [Cross-References to Architecture & Execution Docs](#6-cross-references-to-architecture--execution-docs)

---

## 1. The Operational Lens: Real Practice vs. Theoretical Features

Two practical realities govern every feature decision in ClinicPilot:

### 1.1 How the Solo Clinician Actually Works
- **Clinical Routine**: Rotating across multiple independent clinic branches during evening OPD hours (typically 6:30–9:30 PM).
- **Physical Context**: Arriving fatigued after daytime hospital or academic commitments; standing or sitting in compact consultation spaces; interacting with patients while holding an Android phone in one hand.
- **Cognitive Budget**: Any digital interaction demanding more than 2–3 taps per patient is abandoned during active clinic hours. If a workflow is postponed to "later at home", it is rarely completed.

### 1.2 The Real Operational Bottleneck: Acquisition & Retention
- A nascent or struggling solo clinic does not suffer from lack of digitized paperwork; it suffers from a lack of patient throughput. In early practice observation, a quarter produced 8 new patients and 18 repeat consultations.
- **The Core Bottleneck**: **Patient acquisition and retention**, not record-keeping complexity. Features that uncover lapsed patients, convert satisfied visits into Google Reviews, and track marketing ROI take absolute precedence over bureaucratic charting forms.
- Commercial software vendors build feature bloat to sell enterprise licenses. ClinicPilot prioritizes razor-sharp tools that directly drive clinic viability.

---

## 2. Competitor Screen Breakdown vs. ClinicPilot Capabilities

| Competitor Screen | Functional Role | ClinicPilot Status | Operational Value for Solo Doctors |
|---|---|---|---|
| **Dashboard** | Generic tile grid: patients, appointments, users, masters, settings, templates | **Implemented** (Richer analytical cards; streamlined layout) | High when focused on daily action items rather than dead metrics. |
| **Patient Directory** | Searchable list, phone chips, age/sex filters, quick actions | **Implemented** (Includes area, disease tags, visit timelines) | Critical baseline for rapid lookup. |
| **Appointments** | Time/Billing/Token queues, slot bookings, calendar availability | **Deliberately Deferred** | Low for walk-in practices; creates unnecessary overhead without a receptionist. |
| **Case History** | Per-visit timeline, ICD diagnosis codes, tabs for summary/payments | **Implemented** (16-section Master Record, complaint severity logs) | High for therapeutic longitudinal tracking. |
| **Add Case / Encounter** | Complaint chips, voice/photo capture, Rx writer, attachments | **Implemented** (Complaint progression, posology, pathology logs) | High when optimized for speed. |
| **Finances / Billing** | Daily/Weekly/Monthly income, expenses, payment method split | **Implemented** (Cash memo, P&L, rent prorating, payment splits) | Critical for multi-branch financial clarity. |

---

## 3. Comprehensive Candidate Feature Scoring (Impact, Effort, Risk)

Each candidate is evaluated across three parameters:
- **Impact**: Contribution toward patient retention, revenue generation, and clinical efficiency.
- **Effort**: Engineering complexity and ongoing maintenance overhead.
- **Risk**: Potential for UX friction, data corruption, or adoption failure.

---

### Candidate A: Clinic-Wide Follow-Up Recall List
- **Description**: A consolidated dashboard listing all patients whose scheduled follow-up dates have passed, aggregated across clinics with 1-tap call or WhatsApp actions.
- **Merits**: The highest-leverage retention feature. Re-engaging an existing patient who missed their follow-up is 5x more cost-effective than finding a stranger via advertising.
- **Limitations**: Reliant on the doctor entering a `nextFollowUpDate` during the consultation.
- **Trade-Off**: Introduces one quick date selector chip during checkout to power the recall engine.
- **Scoring**: **Impact: HIGH** | **Effort: SMALL** | **Risk: LOW** (Schema: `visits.nextFollowUpDate`).

---

### Candidate B: Payment-Method Collection Breakdown
- **Description**: Granular breakdown of cash memos into Cash, UPI / QR, Debit/Credit Card, and Direct Bank Transfer.
- **Merits**: Data is already captured on cash memos. Surfacing the cash-vs-digital ratio is essential for cash reconciliation and tax reporting.
- **Limitations**: Informational; does not directly acquire patients.
- **Trade-Off**: None. Pure read projection over existing SQLite records.
- **Scoring**: **Impact: MEDIUM** | **Effort: TINY** | **Risk: NONE**.

---

### Candidate C: Google Review Tracker
- **Description**: Per-patient status tracking: *Not Asked* -> *Review Link Sent* -> *Review Submitted*, plus monthly dashboard review velocity.
- **Merits**: Local Google Business Profile reviews represent the single highest-impact discovery channel for neighborhood clinics. A prompt sent immediately following positive symptom relief maximizes conversion.
- **Limitations**: The app cannot automatically verify third-party Google submissions; tracks outreach intent.
- **Trade-Off**: Two taps per patient to supercharge the clinic's primary organic search channel.
- **Scoring**: **Impact: HIGH** | **Effort: SMALL** | **Risk: LOW**.

---

### Candidate D: Community Camp Manager with Multi-Period ROI
- **Description**: Tracking outreach camp expenses, registrations, and subsequent clinic revenue attributed to that camp at 30, 60, and 90-day intervals.
- **Merits**: Resolves the ambiguity of whether weekend screening camps are profitable or wasted time. Validates return on marketing capital.
- **Limitations**: Requires capturing referral attribution during patient registration.
- **Trade-Off**: Adding an optional referral/camp dropdown during registration.
- **Scoring**: **Impact: HIGH** | **Effort: MEDIUM** | **Risk: MEDIUM** (Attribution degrades if bypassed).

---

### Candidate E: Calendar Appointments & Slot Scheduling
- **Description**: Multi-provider time-slot booking, token queues, and calendar grids.
- **Analysis**: **Deliberately Deferred.** Walk-in practices seeing 5–15 patients per evening do not experience queue congestion. Without a full-time receptionist, the doctor must manually book and update slots, multiplying administrative workload during clinical examinations.
- **Revisit Threshold**: Re-evaluate when practice volume exceeds 20+ scheduled appointments daily or when multi-doctor staffing is introduced.
- **Scoring**: **Impact: LOW (current)** | **Effort: LARGE** | **Risk: HIGH** | **Verdict: DEFER**.

---

### Candidate F: Clinical Case Taking, Prescriptions & Media Attachments
- **Description**: Complaint chips, 16-section homeopathic repertorisation, typed posology, and lab photo attachments.
- **Evolution**: Initially deferred in v0.1 due to documentation complexity. Systematically engineered in v0.4–v0.8 using structured chip pickers, typeahead remedy selectors, and local encrypted camera storage to maintain sub-60-second encounter entry.
- **Scoring**: **Impact: HIGH** | **Effort: LARGE** | **Risk: MEDIUM** (Mitigated via streamlined chip UI).

---

### Candidate G: WhatsApp Deep-Link Quick Actions
- **Description**: 1-tap WhatsApp launch with pre-composed localized templates for follow-up reminders, camp invitations, and diet advice.
- **Merits**: Leverages `whatsapp://send` deep-links. Operates with zero API costs, zero external gateway dependencies, and leaves final sending control in the doctor's hands.
- **Limitations**: Manual send confirmation required per message; bulk automated blasts intentionally avoided to prevent phone number banning.
- **Scoring**: **Impact: HIGH** | **Effort: TINY** | **Risk: LOW**.

---

### Candidate H: Disease-Specific Revenue & Repeat Analytics
- **Description**: Aggregating patient volume, retention rates, and revenue across specific clinical conditions (e.g., Diabetes, PCOS, Chronic Dermatitis, Allergic Rhinitis).
- **Merits**: Enables the practitioner to identify which 2–3 conditions generate predictable repeat revenue, guiding targeted clinical positioning and marketing.
- **Limitations**: Requires standardized condition nomenclature to prevent string fragmentation (e.g., "Migraine" vs. "migraine").
- **Trade-Off**: Implemented via typeahead chip selection with custom entry fallback.
- **Scoring**: **Impact: HIGH** | **Effort: MEDIUM** | **Risk: LOW-MEDIUM**.

---

### Candidate I: Algorithmic Clinic Health Score (0–100)
- **Description**: A composite operational health index calculated each morning, accompanied by 2–3 prioritized clinical actions.
- **Merits**: Transforms the application from a passive digital filing cabinet into an active practice growth coach. Fits quick morning check-in habits.
- **Limitations**: Trust collapses if scoring formula feels arbitrary or opaque. Must transparently explain calculation inputs (e.g., *"Score 84: +4 new patients this week, -3 overdue follow-ups, 2 pending reviews"*).
- **Scoring**: **Impact: HIGH** | **Effort: MEDIUM** | **Risk: MEDIUM**.

---

### Candidate J: Diagnostic Lab & Pharmacy Referral CRM
- **Description**: Directory of neighborhood diagnostic labs, imaging centers, and pharmacies with referral interaction logs.
- **Merits**: Tracks reciprocal referral relationships established during community outreach.
- **Limitations**: Data logging occurs outside active clinical hours.
- **Scoring**: **Impact: MEDIUM** | **Effort: MEDIUM** | **Risk: MEDIUM** (Risk of doctor neglect).

---

### Candidate K: Security Hardening & Encryption at Rest
- **Description**: Biometric / PIN app lock, on-device AES-256 database encryption via SQLCipher, and encrypted `.cpbak` archive exports.
- **Merits**: Protects sensitive patient data against physical phone theft or snooping. Mandatory under modern health data privacy standards.
- **Mitigation of Friction**: Biometric authentication with configurable session timeouts avoids repeated PIN entry during a busy clinic evening.
- **Scoring**: **Impact: CRITICAL** | **Effort: MEDIUM** | **Risk: LOW to build; SEVERE not to build**.

---

## 4. Prioritized Implementation Sequence

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PHASED EXECUTION TRAJECTORY                          │
├─────────────────────────────────────────────────────────────────────────┤
│ PHASE 1: CLOSE THE GROWTH LOOP                                          │
│ 1. Follow-Up Recall List (A)                                            │
│ 2. WhatsApp Deep-Link Actions (G)                                       │
│ 3. Payment-Method Breakdown (B)                                         │
│ 4. Google Review Tracker (C)                                            │
├─────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: STRATEGIC MEASUREMENT                                          │
│ 5. Camp ROI Attribution Engine (D)                                      │
│ 6. Disease Revenue Analytics (H)                                        │
│ 7. Daily Clinic Health Score Coach (I)                                  │
├─────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: CLINICAL DEFENSE & HARDENING                                   │
│ 8. Security Hardening (Biometrics + SQLCipher Encryption) (K)           │
│ 9. Professional PDF Rx Generator with Letterhead Branding               │
├─────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: DELIBERATELY DEFERRED (Post-v1.0 / Scaling Phase)              │
│ 10. Appointments & Time-Slot Booking Queues (E)                         │
│ 11. Full Pharmacy Warehouse Inventory Logistics                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. The Philosophical Distinction: Practice Growth vs. Clinic Administration

```
┌────────────────────────────────────────────────────────────────────────┐
│      COMMERCIAL SOFTWARE          │          CLINICPILOT               │
│     (Clinic Administration)       │       (Practice Growth)            │
├───────────────────────────────────┼────────────────────────────────────┤
│ Focus: Bureaucratic completeness  │ Focus: Patient throughput & profit │
│ Assumes: Full-time receptionist   │ Assumes: Solo doctor on a phone    │
│ Business: Vendor SaaS lock-in     │ Business: 100% Doctor Sovereignty  │
│ Metric: Forms completed           │ Metric: Net margin & recall rate   │
└───────────────────────────────────┴────────────────────────────────────┘
```

The greatest risk in healthcare product development is blindly cloning competitor feature catalogs, resulting in an unwieldy, bloated system that exhausts the solo clinician. ClinicPilot maintains uncompromising focus on the critical question: **Does this feature help the doctor grow and sustain an independent medical practice?**

---

## 6. Cross-References to Architecture & Execution Docs

- **Competitive Landscape**: See [`competitive-analysis.md`](file:///d:/my-quests/side-projects/ClinicPilot/docs/research/competitive-analysis.md) for full benchmark comparisons against Practo, Cliniko, Hompath, and open-source stacks.
- **Monetization & Opportunity**: See [`product-opportunity.md`](file:///d:/my-quests/side-projects/ClinicPilot/docs/research/product-opportunity.md) for market sizing and zero-cost cloud sync design.
- **Clinical UX Guidelines**: See [`ux-analysis.md`](file:///d:/my-quests/side-projects/ClinicPilot/docs/research/ux-analysis.md) for thumb-zone ergonomics and high-contrast OPD readability.
- **Engineering Progress**: See [`progress.md`](file:///d:/my-quests/side-projects/ClinicPilot/docs/project/progress.md) for tracking active sprints, technical debt, and test suite health.
- **Architectural Reference**: See [`PROJECT_HANDOFF_AND_ARCHITECTURE_GUIDE.md`](file:///d:/my-quests/side-projects/ClinicPilot/PROJECT_HANDOFF_AND_ARCHITECTURE_GUIDE.md) for Drift SQLite tables and Riverpod state graph.
