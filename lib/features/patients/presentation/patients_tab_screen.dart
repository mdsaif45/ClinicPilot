import 'package:flutter/material.dart';

import '../../../core/widgets/swipeable_sections.dart';
import 'patients_screen.dart';
import 'recall_screen.dart';

/// The patient directory and the follow-up list under one tab.
///
/// Follow-ups were only reachable from a dashboard card that appears when
/// somebody is overdue — so the one moment the doctor might want to check
/// whether anyone needs chasing, and nobody does, there was no way in. Sitting
/// beside the directory it is always reachable, and it is the same subject:
/// both are lists of patients, one by name and one by who is due.
class PatientsTabScreen extends StatelessWidget {
  const PatientsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directory leads: looking someone up is the far more frequent task.
    return const SwipeableSections(
      labels: ['Directory', 'Follow-ups'],
      children: [
        PatientsScreen(),
        RecallScreen(showAppBar: false),
      ],
    );
  }
}
