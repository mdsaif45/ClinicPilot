import 'package:flutter/material.dart';

import '../../../core/design/tokens.dart';
import '../providers/monthly_statement_provider.dart';

/// Shows the interactive Sort By modal bottom sheet (Image 4).
Future<FinanceSortOption?> showSortByBottomSheet(
  BuildContext context,
  FinanceSortOption current,
) {
  return showModalBottomSheet<FinanceSortOption>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SortByBottomSheet(initialOption: current),
  );
}

class SortByBottomSheet extends StatefulWidget {
  final FinanceSortOption initialOption;

  const SortByBottomSheet({super.key, required this.initialOption});

  @override
  State<SortByBottomSheet> createState() => _SortByBottomSheetState();
}

class _SortByBottomSheetState extends State<SortByBottomSheet> {
  late FinanceSortOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Title and Close 'X'
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),

            // Option Radio Tiles
            for (final option in FinanceSortOption.values) ...[
              _SortOptionTile(
                label: option.label,
                isSelected: _selected == option,
                onTap: () => setState(() => _selected = option),
              ),
              const SizedBox(height: Spacing.xs),
            ],

            const SizedBox(height: Spacing.md),

            // Full-width Done Button
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md, horizontal: Spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // Standard green checkmark circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.dividerColor.withAlpha(180),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
