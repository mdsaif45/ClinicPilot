import 'package:flutter/material.dart';

import '../../../core/widgets/section_switch.dart';
import '../../cashmemo/presentation/cash_memo_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';

/// Money in and money out under one tab.
///
/// They were separate destinations, which meant two of the five nav slots went
/// to halves of the same question. Combining them frees a slot and puts income
/// beside spending, where comparing the two costs one tap instead of a trip
/// through the bar.
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  // Cash memo leads: recording income is the far more frequent task during a
  // clinic evening.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSwitch(
          labels: const ['Cash Memo', 'Expenses'],
          index: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
        Expanded(
          child: IndexedStack(
            index: _index,
            children: const [
              CashMemoScreen(),
              ExpensesScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
