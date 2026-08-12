import 'package:flutter/material.dart';

import '../../../core/design/tokens.dart';
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
        _SectionSwitch(
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

/// Text-only section switch: the selected label is bold and full contrast, the
/// other is muted. Deliberately not a pill or a tab bar — with two options the
/// weight difference is enough, and it keeps the top of the screen quiet.
class _SectionSwitch extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const _SectionSwitch({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final animate = !MediaQuery.of(context).disableAnimations;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.xl),
            InkWell(
              borderRadius: Radii.smAll,
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: Spacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: animate ? Motion.fast : Duration.zero,
                      curve: Motion.curve,
                      style: (theme.textTheme.titleMedium ??
                              const TextStyle())
                          .copyWith(
                        color: i == index
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight:
                            i == index ? FontWeight.w700 : FontWeight.w400,
                      ),
                      child: Text(labels[i]),
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Underline marks the selection without adding a control
                    // the eye has to parse.
                    AnimatedContainer(
                      duration: animate ? Motion.base : Duration.zero,
                      curve: Motion.curve,
                      height: 2,
                      width: i == index ? 24 : 0,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: Radii.pillAll,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
