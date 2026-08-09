<!-- Keep this short. Explain why, not just what — the diff shows what changed. -->

## What and why

Closes #

## Checklist

- [ ] `flutter analyze` is clean
- [ ] `flutter test` passes
- [ ] No real patient data in code, tests, screenshots or this description

## Schema changes

<!-- Delete this section if you did not touch lib/core/database/tables/ -->

- [ ] `schemaVersion` bumped
- [ ] Every `addColumn` guarded with `_addColumnIfMissing`
- [ ] Renamed columns copied before anything depends on them
- [ ] Migration test added, building the **previous** schema and asserting zero row
      loss and idempotency
- [ ] Verified by upgrading over the previous release on a device or emulator

## Verification

<!-- What you actually ran, and the result. Not what you expect to happen. -->
