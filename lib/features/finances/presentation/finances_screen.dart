import 'package:flutter/material.dart';

import '../../../core/widgets/swipeable_sections.dart';
import '../../cashmemo/presentation/cash_memo_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';

/// Money in and money out under one tab.
///
/// They were separate destinations, which meant two of the five nav slots went
/// to halves of the same question. Combining them frees a slot and puts income
/// beside spending, where comparing the two costs one tap instead of a trip
/// through the bar.
class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cash memo leads: recording income is the far more frequent task during
    // a clinic evening.
    return const SwipeableSections(
      labels: ['Cash Memo', 'Expenses'],
      children: [
        CashMemoScreen(),
        ExpensesScreen(),
      ],
    );
  }
}
