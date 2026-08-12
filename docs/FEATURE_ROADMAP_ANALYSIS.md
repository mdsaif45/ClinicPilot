# ClinicPilot — Feature Analysis & Roadmap

Analysis of the six competitor screens against ClinicPilot's current state, the
original requirements, and how Dr. Zaid actually works.

---

## 0. The lens

Two facts should decide every item below.

**How he works.** Two clinics, alternate evenings, 6:30–9:30 PM. He arrives at
7:30–8:00 because college ends at 6. He is standing, between patients, on a
phone. Anything costing more than a few taps per patient will not get used
during clinic — it will get postponed to "later" and then never done.

**What is actually broken.** Three months produced 8 new patients and 18 repeat
visits. The bottleneck is **acquisition**, not record-keeping. Features that
help him see and fix acquisition beat features that digitise paperwork he is
already doing on paper without complaint.

The competitor is a general clinic-management product sold to many doctors. It
optimises for feature-list completeness. ClinicPilot has one user and one
problem. Copying the list wholesale would trade a sharp tool for a blunt one.

---

## 1. What the competitor screens show

| Screen | What it does | ClinicPilot today |
|---|---|---|
| Dashboard | Tile grid: patients, appointments, users, masters, settings, templates, support | Have — richer analytics, no tile grid |
| Patients | Searchable list, phone chips, age/sex, quick actions | Have — plus code, area, disease |
| Appointments | Time / Billing / Token views, slot booking, availability | **Missing entirely** |
| Case History | Per-visit timeline, ICD-coded diagnosis, Summary / Payments / Records tabs | Partly — timeline yes, diagnosis codes and records no |
| Add Case | Complaint chips, typed/voice/photo capture, prescription, next appointment, bills, attachments | **Missing** — we capture disease + complaint only |
| Finances | Today/Weekly/Monthly/Quarterly, earnings vs spends, collection split by payment method | Mostly — no payment-method breakdown, no quarterly |

---

## 2. Feature candidates

Each is scored on **impact** (does it move the Rs 50k goal), **effort**, and
**risk**. Ordered by what I would actually build.

---

### A. Follow-up recall list — clinic-wide

Overdue follow-ups across all patients, not one profile at a time. Tap to call
or WhatsApp.

- **Good.** This is the single highest-value item in this document. He already
  has 18 repeat visits per quarter and the data to find lapsed patients. A
  patient who came twice and stopped is warmer than any stranger a leaflet
  reaches. Directly attacks the acquisition-vs-retention gap using patients he
  has already paid to acquire.
- **Bad.** Only as good as the follow-up dates entered. If he skips the date
  field the list stays empty.
- **Trade-off.** Adds one field to the visit flow to make the list work.
- **Risk.** Low. Schema exists (`visits.nextFollowUpDate`), UI now exists.
- **Impact.** High. **Effort.** Small.

---

### B. Payment-method breakdown

Split collections by Cash / UPI / Card / Bank, as the Finances screen does.

- **Good.** Data is already captured on every memo and currently unused. Tells
  him how much is cash — which matters for reconciliation and for knowing what
  actually reached the bank.
- **Bad.** Interesting rather than decisive; it does not bring patients.
- **Trade-off.** None. Pure read of existing data.
- **Risk.** None.
- **Impact.** Medium. **Effort.** Tiny.

---

### C. Google review tracker

Per-patient: asked / submitted / rating. Dashboard: reviews this month, total.

- **Good.** The original plan names Google Reviews the **single highest-impact
  local marketing factor**, with a target of 100 in a year. He currently tracks
  none. A prompt after a successful visit converts satisfaction into the thing
  that actually drives discovery.
- **Bad.** The app cannot verify a review was left; it records that he asked.
- **Trade-off.** Two taps per patient for a marketing channel the plan ranks
  first.
- **Risk.** Low. One nullable column or a small table.
- **Impact.** High — indirect but on the critical path. **Effort.** Small.

---

### D. Camp manager with ROI

Camp name, date, cost, attendance, patients generated, revenue at 30/90 days.

- **Good.** He runs camps already and cannot tell which paid off. This is the
  difference between "camps feel useful" and "the diabetes camp returned
  Rs 18,000 on Rs 4,000". Directly answers where to spend the next Sunday.
- **Bad.** Needs attribution — linking a patient back to the camp that produced
  them. That is one extra field at registration, and it must be filled or the
  ROI is fiction.
- **Trade-off.** Real schema work for a feature used monthly, not daily.
- **Risk.** Medium. Attribution decays if the field is skipped.
- **Impact.** High. **Effort.** Medium.

---

### E. Appointments / scheduling

Slot booking, day view, availability.

- **Good.** The competitor leads with it.
- **Bad.** **I would not build this.** He sees 1–5 patients an evening in a
  walk-in practice. Slot booking solves queue congestion he does not have, and
  every appointment must be entered by someone — with no receptionist, that is
  him, during clinic. It would add work and remove none.
- **Trade-off.** Large build for a problem the practice does not have yet.
- **Risk.** High — the classic case of copying a competitor's feature without
  their context. Revisit at 15+ patients a day.
- **Impact.** Low now. **Effort.** Large. **Verdict: defer.**

---

### F. Case taking, prescriptions, attachments

Complaint chips, typed/voice/photo case notes, prescription, file attachments.

- **Good.** The competitor's strongest screens. Homeopathy genuinely needs long
  case histories and he keeps them today on paper.
- **Bad.** Explicitly **out of scope** in the original plan, and for a good
  reason: "Patient history is huge." Homeopathic case taking is 20+ fields and
  10–20 minutes per patient. Typing that on a phone during a 3-hour evening
  would slow consultations, and a half-finished case record is worse than a
  paper one because it looks authoritative.
- **Trade-off.** Also raises the stakes on security: prescriptions and case
  notes are far more sensitive than the current revenue data, and the app has
  no lock, no encryption at rest, and a plaintext CSV export.
- **Risk.** High — scope, adoption, and data sensitivity together.
- **Impact.** Medium. **Effort.** Very large. **Verdict: defer past v1.0.**

---

### G. WhatsApp quick actions

Tap a patient to open WhatsApp with a pre-filled follow-up or camp message.

- **Good.** The original plan leans on WhatsApp throughout. A deep link is
  cheap, needs no API, and turns the recall list (A) into action rather than
  a list to read.
- **Bad.** Opens WhatsApp rather than sending; he still taps send. Bulk
  messaging risks a spam perception if overused.
- **Trade-off.** Manual send is the correct default here anyway — automated
  clinical messages are a consent question, not a UX one.
- **Risk.** Low.
- **Impact.** Medium-high, paired with A. **Effort.** Tiny.

---

### H. Disease analytics with revenue

Extend disease counts to revenue and repeat rate per condition.

- **Good.** The plan tells him to become "the doctor of 2–3 conditions" —
  Diabetes, PCOS, Thyroid. That decision needs data: which condition brings
  repeat visits and revenue, not just headcount. A condition seen often but
  never returning is a worse bet than one seen rarely that returns monthly.
- **Bad.** Disease is free text, so "Migraine" and "migraine " split. Needs
  normalisation or a picker.
- **Trade-off.** Constraining the field slightly to gain reliable grouping.
- **Risk.** Low-medium — existing free-text data needs cleaning.
- **Impact.** High for positioning. **Effort.** Medium.

---

### I. Clinic health score

One 0–100 number each morning with two or three suggested actions.

- **Good.** Named in the original plan as the potential signature feature.
  Turns the app from a ledger into a coach. Fits his actual behaviour — he
  opens the app briefly, not for a study session.
- **Bad.** A composite score is only as honest as its weights. A number that
  drifts without an explanation erodes trust faster than no number.
- **Trade-off.** Must always show its working: "82 — because 4 new patients,
  2 reviews, 3 overdue follow-ups."
- **Risk.** Medium — easy to build something that looks smart and means little.
- **Impact.** High if honest. **Effort.** Medium.

---

### J. Pharmacy / lab referral network

Contacts, visit log, patients referred by each.

- **Good.** The plan devotes a whole section to walking into 10 pharmacies and
  5 labs. Tracking who was visited and who actually sends patients turns that
  from a chore into a measurable channel.
- **Bad.** Data entry happens outside clinic hours, which is when he is least
  likely to open the app.
- **Trade-off.** Small table; genuine value only if maintained.
- **Risk.** Medium — likeliest feature to be built and then unused.
- **Impact.** Medium. **Effort.** Medium.

---

### K. Security hardening

App lock (PIN/biometric), database encryption, encrypted export.

- **Good.** The app holds names, phones, ages and conditions. `SECURITY.md`
  already documents that there is no app lock, no encryption at rest, and that
  CSV export is plaintext. Any move toward case notes (F) makes this mandatory
  rather than advisable.
- **Bad.** A lock adds friction to an app opened many times an evening.
  Biometric with a generous timeout is the only version he will tolerate.
- **Trade-off.** Slight daily friction against a category of risk that cannot
  be undone once a phone is lost.
- **Risk.** Low to build. High **not** to build.
- **Impact.** High (risk reduction). **Effort.** Medium.

---

## 3. What I would build, in order

**Now — completes the growth loop**

1. **A. Follow-up recall list** — turns existing patients into revisits
2. **G. WhatsApp actions** — makes A actionable in one tap
3. **B. Payment breakdown** — free, data already captured
4. **C. Google review tracker** — the plan's highest-impact channel

**Next — makes the strategy measurable**

5. **D. Camp ROI** — tells him which outreach pays
6. **H. Disease revenue** — decides the 2–3 conditions to own
7. **I. Clinic health score** — the daily coach, only once the inputs above exist

**Before any clinical data**

8. **K. Security hardening** — mandatory prerequisite for F

**Deferred, deliberately**

9. **E. Appointments** — revisit at 15+ patients/day
10. **F. Case taking** — revisit after 30 days of real v1.0 use

---

## 4. The honest summary

The competitor screens are a **clinic management** product. ClinicPilot is a
**practice growth** product. That difference is the reason to build 1–7 and
skip 9–10 for now.

Items 1–4 close a loop the app currently leaves open. It can already tell him
that 60% of patients came from Google and that Clinic B loses money — but not
who to call back, whether he asked for the review, or which camp paid. Those
four are small, and together they turn measurement into action.

The largest risk in this document is not any single feature. It is building the
competitor's list, ending up with a worse version of a product that already
exists, and losing the one thing ClinicPilot does that they do not: telling a
solo doctor **why** his practice is or is not growing.
