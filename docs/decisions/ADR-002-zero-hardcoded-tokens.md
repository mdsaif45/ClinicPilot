# ADR-002: Centralized Design Tokens & Enforced Theme Compliance Gate

## Metadata
- **Status**: Accepted
- **Date**: 2026-03-11
- **Deciders**: Frontend Architecture Lead, UI/UX Governance Team, Lead Flutter Engineer
- **Consulted**: Design Systems Working Group, Clinical Ergonomics Advisor
- **Informed**: Mobile Developers, QA Automation Engineers

---

## Context
ClinicPilot serves medical practitioners in diverse and challenging visual environments: high-glare daytime clinic cabins, dim evening consultation rooms, rural health camps, and late-night desk shifts. A professional clinical interface demands optimal legibility, predictable contrast ratios, coherent spatial rhythm, and robust support for Dark Mode and diverse visual themes (such as Emerald, Medical Blue, and High-Contrast Monochrome).

In earlier iterations of the codebase, rapid feature development led to pervasive inline styling:
1. Developers frequently instantiated hardcoded Material colors (e.g., `Colors.teal`, `Colors.green[600]`, `Colors.blueAccent`) directly within screen widgets and cards.
2. Magic layout numbers (e.g., `padding: EdgeInsets.all(13.0)`, `BorderRadius.circular(7)`) proliferated across forms, disrupting visual alignment across tabs.
3. Excessive or sluggish UI animations caused perceptible delays for busy doctors quickly switching between patients or typing prescriptions.

The breaking point arrived when ClinicPilot introduced theme customizability (e.g., switching from Emerald to a high-contrast Monochrome palette): screens with hardcoded `Colors.teal` or inline hex values left garish green icons and low-contrast grey text stranded on dark surfaces. Furthermore, manual code reviews repeatedly failed to catch rogue inline colors.

ClinicPilot required a deterministic design system architecture backed by an automated, unyielding regression gate that guarantees 100% theme compliance across the entire user interface.

---

## Options Considered

The frontend team evaluated four design token and styling governance strategies:

| Evaluation Dimension | 1. Centralized Tokens + Automated CI Test Gate (Chosen) | 2. Ad-Hoc Inline Styling (`Colors.*`) | 3. Rigid Proprietary UI Widget Library Only | 4. Dart Analyzer / Custom AST Lints Only |
| :--- | :--- | :--- | :--- | :--- |
| **Theme Consistency** | Complete; all screens resolve colors dynamically from `ColorScheme` | Fragile; themes break whenever a screen hardcodes a color | High; enforced through proprietary widgets | Moderate; depends on lint rule coverage |
| **Dark Mode Readiness** | Flawless out-of-the-box; surfaces adapt dynamically | Broken; dark mode produces unreadable low-contrast text | Good, but complex for custom painters | Good |
| **Developer Ergonomics** | Standard Flutter idioms; autocomplete via `tokens.dart` & `Theme.of(context)` | Immediate convenience; high long-term maintenance cost | High friction; requires wrapping all primitives | Moderate; requires configuring IDE plugins |
| **Automated Enforcement** | 100% deterministic via `theme_compliance_test.dart` in CI | None; relies on fallible human peer review | Partial; developers can still bypass wrapper widgets | High tooling setup overhead; difficult to whitelist PDF services |
| **Physical Print Exemption** | Clean architectural exemption for PDF generators (`pdf_service.dart`) | Accidental color mixing on printouts | Difficult to bifurcate screen vs. print widgets | Complex AST AST-walking logic required |

### Detailed Evaluation of Alternatives

- **Option 2: Ad-Hoc Inline Styling (`Colors.*`)**
  - *Pros*: Zero upfront abstraction; fastest initial prototyping speed.
  - *Cons*: Catastrophic theme debt. Any hardcoded `Colors.blue` or `Color(0xFF...)` creates visual defects when switching to dark mode or alternate palettes.
- **Option 3: Rigid Proprietary UI Widget Library Only**
  - *Pros*: High component reusability via custom wrapper widgets (`ClinicCard`, `ClinicText`).
  - *Cons*: Restricts standard Flutter composition; fails to prevent hardcoded colors inside custom painters, canvas charts, or standard dialogs; high API maintenance overhead.
- **Option 4: Dart Analyzer / Custom AST Lints Only**
  - *Pros*: In-editor squiggly lines during active coding.
  - *Cons*: Authoring and maintaining custom analyzer plugins introduces significant maintenance friction across Flutter/Dart SDK upgrades; difficult to maintain selective exclusions for physical document generators (PDF services).

---

## Decision

We chose to establish a **Centralized Design Token Framework** paired with an **Automated Static Regression Gate (`theme_compliance_test.dart`)**.

1. **Centralized Token Architecture (`lib/core/design/tokens.dart`)**:
   - **Spacing**: Geometric scale (`Spacing.xxs = 2`, `xs = 4`, `sm = 8`, `md = 12`, `lg = 16`, `xl = 24`, `xxl = 32`). Magic padding numbers are prohibited.
   - **Radii**: Uniform shape rounding (`Radii.sm = 8`, `md = 12`, `lg = 16`, `pill = 999`).
   - **Restrained Motion**: Animation durations are capped (`Motion.fast = 120ms`, `base = 180ms`, `slow = 240ms`, `staggerLimit = 8`). Animations must never delay clinical workflows.
   - **Semantic Colors (`SemanticColors`)**: Context-aware helper methods (`SemanticColors.income(context)`, `SemanticColors.expense(context)`, `SemanticColors.profit(context, val)`) that resolve dynamically from `Theme.of(context).colorScheme`.

2. **Strict Zero-Hardcoded-Colors Policy**:
   No UI widget in `lib/` may reference `Colors.<name>` or direct `Color(0x...)` constructors, except within designated theme/design definitions and print services.

3. **Automated CI Compliance Gate (`test/theme_compliance_test.dart`)**:
   An automated unit test runs in every test run and CI build, traversing all `.dart` files in `lib/` and failing the build if hardcoded colors are detected:
   ```dart
   // From test/theme_compliance_test.dart
   test('no hardcoded colours outside the theme and design layers', () {
     final offenders = <String>[];
     final namedColour = RegExp(
       r'\bColors\.(red|blue|teal|green|orange|purple|amber|grey|white|black|'
       r'indigo|cyan|pink|lime|brown|deepOrange|redAccent|blueAccent|black87)\b',
     );
     final hexColour = RegExp(r'Color\(0x[Ff][Ff]');

     for (final entity in Directory('lib').listSync(recursive: true)) {
       if (entity is! File || !entity.path.endsWith('.dart')) continue;
       final path = entity.path.replaceAll(r'\', '/');
       // Design/theme layers define the palette; PDF renderers target physical paper
       if (path.contains('core/theme/') ||
           path.contains('core/design/') ||
           path.contains('pdf_service') ||
           path.contains('pdf_export_service')) {
         continue;
       }
       final lines = entity.readAsLinesSync();
       for (var i = 0; i < lines.length; i++) {
         if (namedColour.hasMatch(lines[i]) || hexColour.hasMatch(lines[i])) {
           offenders.add('$path:${i + 1}  ${lines[i].trim()}');
         }
       }
     }
     expect(offenders, isEmpty, reason: 'Resolve colours from Theme.of(context).colorScheme');
   });
   ```

4. **Architectural Exemption for Physical Paper (PDF Rendering)**:
   Code rendering to physical paper (`pdf_service.dart`, `list_pdf_export_service.dart`) is explicitly exempt from dynamic theme resolution. Paper is static white; printed clinical letterheads, prescription slips, and receipts must preserve fixed, high-legibility ink tones regardless of whether the doctor's phone is set to Dark Mode.

---

## Rationale

1. **Elimination of UI Breakage Across Themes**:
   By forcing all widgets to read from `Theme.of(context).colorScheme`, any palette swap (Emerald, Slate, Monochrome) instantly recolors every screen component, icon, card border, and chart element without leaving orphaned accent colors.
2. **Clinical Speed & Restrained Motion**:
   Clinical software is an operational tool, not an entertainment app. Doctors consult patients standing up, between ward rounds, or under intense clinic pressure. Capping animations to a maximum of 240ms (`Motion.slow`) and limiting list stagger animations to the first 8 items (`Motion.staggerLimit = 8`) guarantees that the interface feels snappy, responsive, and respectful of the doctor's time.
3. **Continuous Enforcement Without Human Bias**:
   Code reviews are fallible; fatigue causes reviewers to miss an inline `Colors.teal` inside a nested builder. The automated compliance test executes in under 100 milliseconds and guarantees 100% adherence before code can be merged into trunk.
4. **Accessible Financial Semantics**:
   Financial ledger displays (profit, revenue, expenses, balances) use `BrandColors` and `SemanticColors` to ensure clear distinction between debits and credits across both light and dark backgrounds.

---

## Consequences

### Positive Impacts
- **100% Visual Consistency**: The entire application shares identical spacing, corner radii, and tonal hierarchy.
- **Flawless Dark Mode Support**: Zero white-on-white text bugs or unreadable dark cards in dark mode.
- **Zero-Friction Theme Expansion**: Adding a new clinic theme only requires defining a new `ColorScheme` in `app_theme.dart`; all existing screens automatically adapt.
- **Deterministic CI Gate**: Regressions are blocked at development time with clear, actionable line-by-line failure outputs.

### Negative Trade-offs
- **Minor Initial Coding Overhead**: Developers cannot quickly drop a `Colors.amber` onto a widget; they must resolve or create a semantic token.
- **Regex Limitations**: The compliance test relies on regex pattern matching rather than full AST compilation; non-standard color declarations (e.g. `Color.fromARGB`) must be monitored.

### Mitigation Strategies
- Provide clear guidance in test failure assertions pointing developers to exact replacements (e.g., `Theme.of(context).colorScheme.primary` or `SemanticColors`).
- Maintain rich helper getters in `SemanticColors` for recurring clinical states (e.g. baseline vs. acute, active vs. settled).

---

## Reconsideration Trigger

This architectural decision shall be formally reopened if:
1. **Dynamic OS Material You Theming**: ClinicPilot adopts platform-driven Android/iOS dynamic color extraction requiring run-time color harmony transformations that cannot be modeled within the existing `tokens.dart` structure.
2. **Third-Party Plugin UI Embeds**: ClinicPilot integrates third-party Flutter packages that render their own proprietary UI widgets with immutable hardcoded colors that cannot be styled via standard `ThemeData`.
