import 'package:flutter/material.dart';

import '../../../core/widgets/section_switch.dart';
import 'patients_screen.dart';
import 'recall_screen.dart';

/// The patient directory and the follow-up list under one tab.
///
/// Follow-ups were only reachable from a dashboard card that appears when
/// somebody is overdue — so the one moment the doctor might want to check
/// whether anyone needs chasing, and nobody does, there was no way in. Sitting
/// beside the directory it is always reachable, and it is the same subject:
/// both are lists of patients, one by name and one by who is due.
class PatientsTabScreen extends StatefulWidget {
  const PatientsTabScreen({super.key});

  @override
  State<PatientsTabScreen> createState() => _PatientsTabScreenState();
}

class _PatientsTabScreenState extends State<PatientsTabScreen> {
  // Directory leads: looking someone up is the far more frequent task.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSwitch(
          labels: const ['Directory', 'Follow-ups'],
          index: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
        Expanded(
          // IndexedStack rather than swapping children: the directory keeps
          // its scroll position and whatever is typed in the search box while
          // the doctor checks the follow-up list.
          child: IndexedStack(
            index: _index,
            children: const [
              PatientsScreen(),
              RecallScreen(showAppBar: false),
            ],
          ),
        ),
      ],
    );
  }
}
