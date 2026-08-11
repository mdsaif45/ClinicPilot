import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Currency value with tabular figures so stacked amounts align, and optional
/// sign colouring for profit/loss.
class MoneyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool colorBySign;

  const MoneyText({
    super.key,
    required this.amount,
    this.style,
    this.colorBySign = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      Formatters.formatCurrency(amount),
      style: AppTheme.tabularFigures(
        base?.copyWith(
          color: colorBySign ? AppTheme.moneyColor(context, amount) : base.color,
          fontWeight: base.fontWeight ?? FontWeight.w600,
        ),
      ),
    );
  }
}
