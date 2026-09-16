# ClinicPilot — Product & Design Principles

> **Five Non-Negotiable Axioms Governing Engineering, Clinical UX, and Product Architecture**

---

## The Philosophy of Clinical Constraints

Most modern software is engineered in well-lit corporate offices with high-speed fiber internet, dual monitors, and continuous air conditioning. 

**ClinicPilot is engineered for the trenches**:
- A humid, crowded, 80-square-foot consultation chamber in Babu Bazar.
- Rain pouring outside, fluctuating power, spotty 2G/4G connectivity.
- Thirty weary patients waiting outside in a narrow hallway.
- A doctor working at breakneck speed, examining tongues, taking pulses, selecting homeopathic potencies, dispensing sugar globules, and handing out bills—all without an assistant.

In this environment, theoretical design elegance is worthless if it creates operational latency. The following **Five Non-Negotiable Principles** take precedence over all feature requests, UI trends, and corporate software conventions.

---

## Principle 1: Speed > Polish
*Every tap counts in a 3-minute patient consultation.*

```
Rule of Thumb: If an action takes more than 3 taps or 5 seconds, it is broken.
```

### The Rationale
In an evening outpatient department (OPD), time is the doctor’s single scarcest asset. If recording an encounter takes 6 minutes, a queue of 30 patients requires 3 full hours of relentless data entry. Doctors will not sacrifice patient rapport or their own sanity to satisfy complex digital forms; they will simply revert to paper slips or abandon the app entirely.

### Engineering & UX Mandates
1. **Sub-200ms Search**: Patient search across thousands of records must return results instantly on keystroke using SQLite indexed queries (`fts5` or prefix-indexed B-trees).
2. **Eliminate Multi-Step Wizards**: Never force a doctor through a 5-step modal wizard to perform a routine task. Single-surface sheets with smart defaults beat progressive disclosure during active clinic hours.
3. **Optimistic UI Execution**: Actions (saving a visit, issuing a cash memo, updating stock) must register immediately in the UI. Background persistence must never block user interaction.
4. **Zero Animation Lag**: Disable unnecessary decorative transitions that delay user input. Page transitions must be snappy (under 150ms).

### Anti-Patterns to Reject
- Modal dialogs with confirmation buttons for routine data entry (e.g. *"Are you sure you want to add this remedy?"*).
- Multi-page form steps that require tapping "Next" three times before reaching the prescription box.
- Mandatory fields for non-vital metadata (e.g., forcing postal code, email address, or alternate phone number before saving a patient).

---

## Principle 2: Offline > Cloud
*Clinics have terrible connectivity; the app must never show a loading spinner waiting on the network.*

```
Rule of Thumb: The network cable can be physically severed, and ClinicPilot must function at 100% capacity indefinitely.
```

### The Rationale
Urban and rural clinic chambers are notoriously shielded from cellular reception—located in dense alleyways, basements, or under corrugated tin roofs. Any software architecture that blocks a UI thread waiting for an HTTP API response, an OAuth authentication token, or remote cloud database sync will fail catastrophically during an active consultation session.

### Engineering & UX Mandates
1. **100% Local-First Engine**: Drift ORM on SQLite is the primary and definitive source of truth. All reads and writes hit on-device flash storage.
2. **Zero Network Spinners**: There must be **zero blocking spinners** on the critical clinical path. The words *"Connecting to server..."* must never appear on a screen during an OPD session.
3. **Decoupled Background Sync**: Cloud backup (e.g., Google Drive sync) runs as an asynchronous, non-blocking background job triggered only when the app is idle or on explicit doctor command.
4. **Fail-Safe Startup**: App launch must be instantaneous (under 800ms) with zero online licensing checks or remote telemetry handshakes.

### Anti-Patterns to Reject
- Remote authentication (Firebase Auth / Supabase Auth) that locks the doctor out if their device is offline for 48 hours.
- Cloud-dependent auto-complete APIs that stall text entry when connectivity drops.
- Synchronous cloud sync that delays saving a patient record until a remote server responds with HTTP 200 OK.

---

## Principle 3: Ergonomic Flow
*The doctor frequently stands up to examine patients, touches the screen with one hand, and uses physical keyboards when seated.*

```
Rule of Thumb: Key clinical actions must be reachable by the thumb of a single hand, or navigable via keyboard hotkeys without touching the screen.
```

### The Rationale
Clinical work is physically dynamic. The physician does not sit static in front of a monitor. Dr. Zaid stands up to inspect a patient's throat, walks to the dispensing counter, holds the phone in one hand while counting sugar pills into a paper packet with the other, and sits down to review previous case notes. The interface must adapt seamlessly to these postural changes.

### Engineering & UX Mandates
1. **One-Handed Thumb Zone**: Primary action targets (Save, Dispense, Print, Switch Clinic) must reside in the bottom 40% of the screen. Critical triggers must never be placed exclusively in top app bars.
2. **Generous Touch Targets**: All interactive elements must maintain a minimum bounding box of **48x48 dp** to prevent mis-taps when moving quickly or wearing clinical gloves.
3. **Adaptive Form Factor**:
   - On **Mobile**: Bottom sheets, sticky bottom action bars, and swipeable tab navigation.
   - On **Tablet / Desktop**: Responsive two-pane master-detail views with full hardware keyboard navigation (`Tab` to advance, `Enter` to submit, `Esc` to dismiss).
4. **High-Contrast Typography**: Consultation chambers often have dim or flickering fluorescent lighting. UI text must maintain a minimum contrast ratio of 4.5:1 against surfaces, utilizing crisp system typography without low-contrast pastels.

### Anti-Patterns to Reject
- Tiny icon buttons clustered in the top-right corner of the screen.
- Deeply nested dropdown trees requiring precision multi-finger pinch or scroll to select a remedy.
- Horizontal carousel pickers that require delicate finger swipes to locate common potencies.

---

## 4. Principle 4: Local-First Data Sovereignty
*The doctor owns their data forever without vendor lock-in or third-party surveillance.*

```
Rule of Thumb: The doctor's patient records are sacred medical confidences. ClinicPilot is a vault, not an aggregator.
```

### The Rationale
Healthcare technology companies routinely monetize practitioner data—packaging anonymized patient charts, tracking prescribing trends for pharmaceutical companies, or holding records hostage behind exorbitant export fees. For independent homeopathic and integrative doctors, data privacy is both an ethical duty and a clinical necessity. Case records contain the most vulnerable psychological and physical disclosures of patients' lives.

### Engineering & UX Mandates
1. **Hardware-Accelerated Encryption**: On-device SQLite databases are secured with SQLCipher AES-256 encryption. The encryption key is tied to the doctor's biometric credentials or a master PIN, never sent to remote servers.
2. **Open Standard Data Portability**: Doctors can export their entire practice database at any moment into open, non-proprietary formats: **standard SQLite file, unencrypted CSV archives, and standardized clinical PDF records**.
3. **Zero Telemetry & Ad Trackers**: The codebase contains zero third-party analytics SDKs (no Google Analytics, no Facebook SDK, no Mixpanel, no Adjust). Crash logs stay strictly on-device unless manually shared by the doctor for technical support.
4. **Permanent Offline Access**: Even if the doctor ceases paying for premium features or deletes the app repository, the local database remains readable and decryptable via standard open-source tools.

### Anti-Patterns to Reject
- Proprietary binary database blobs that can only be reopened using a paid ClinicPilot license.
- "Export" features that require submitting a support ticket or waiting 48 hours for a download link.
- In-app advertisements, sponsored drug suggestions, or pharmaceutical ad banners.

---

## 5. Principle 5: Cognitive Offloading
*Smart defaults, repertorial auto-suggestions, and quick dosage presets eliminate mental fatigue.*

```
Rule of Thumb: Never ask the doctor to type what the system can safely predict.
```

### The Rationale
By patient #28 at 9:15 PM, cognitive exhaustion sets in. If the software demands that the doctor manually type *"4 pills twice daily after meals for 14 days"* thirty times every evening, errors proliferate and documentation quality degrades. The software must absorb repetitive mental chores, allowing the doctor to focus 100% of their intellect on differential diagnosis and patient empathy.

### Engineering & UX Mandates
1. **Context-Aware Smart Defaults**:
   - Dispensing vehicle defaults to the doctor's most common preference (e.g. *Globules #20 in Sugar of Milk*).
   - Duration defaults to standard clinic review intervals (e.g. *14 days* for chronic cases, *3 days* for acute).
   - Consultation fee automatically populates based on the active clinic’s profile and patient visit type (New vs. Follow-up).
2. **Repertorial & Remedy Auto-Complete**:
   - As the doctor types `Nux`, the system instantly suggests `Nux Vomica` with its most commonly prescribed potencies (30C, 200C, 1M) accessible in single-tap pill chips.
3. **17-Section Visual Triage**: Case taking organizes the complex totality of symptoms into clean, scannable accordions with color-coded completion badges. The doctor can record 1 section or all 17 sections without validation barriers.
4. **One-Tap Posology Presets**: Standard homeopathic posology rules (e.g. *TDS (3 times/day)*, *BD (2 times/day)*, *OD (once daily)*, *Stat (immediately)*, *SOS (as needed)*) must be selectable via dedicated chip buttons.

### Anti-Patterns to Reject
- Free-form text fields without historical auto-suggestions.
- Blank forms that do not remember the doctor’s most frequent prescription combinations.
- Complex hierarchical menus that force the doctor to categorize a symptom before typing it.

---

## Principle Priority Matrix

When product decisions, design conflicts, or technical trade-offs arise, resolve them using this strict hierarchy:

```
Speed (1) > Offline Reliability (2) > Data Sovereignty (3) > Ergonomic Flow (4) > Visual Polish (5)
```

If a feature makes the app look more beautiful but adds 300ms of lag to the consultation loop, **it is rejected**. If a feature enables real-time cloud collaboration but risks locking out an offline doctor, **it is rejected**. We build for Dr. Zaid in the clinic, under pressure, saving lives and building livelihoods.
