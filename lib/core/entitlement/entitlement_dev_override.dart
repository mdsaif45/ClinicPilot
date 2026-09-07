import 'package:flutter/foundation.dart';

/// Local developer switch to preview Pro-gated screens without redeeming a
/// voucher or seeding trial state by hand.
///
/// Flip this to `true` while working on a Pro feature, then flip it back
/// before committing. It has no effect on a release build: `kDebugMode` is
/// `false` there, so [forceProInDebug] always evaluates to `false` and this
/// file compiles away to nothing regardless of the literal below.
const bool _forceProSwitch = false;

/// Whether Pro entitlement should be forced on for local development.
///
/// True only when both this is a debug build AND [_forceProSwitch] is
/// flipped on — so a stray `true` left in this file cannot leak into a
/// release or profile build and unlock Pro for real users.
bool get forceProInDebug => kDebugMode && _forceProSwitch;
