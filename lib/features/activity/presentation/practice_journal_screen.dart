import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../providers/practice_journal_provider.dart';
import 'widgets/double_activity_ring.dart';

/// Standalone Clinical Practice Journal screen inspired by Google Fit Journal layout.
class PracticeJournalScreen extends ConsumerStatefulWidget {
  const PracticeJournalScreen({super.key});

  @override
  ConsumerState<PracticeJournalScreen> createState() => _PracticeJournalScreenState();
}

class _PracticeJournalScreenState extends ConsumerState<PracticeJournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dayGroups = ref.watch(practiceJournalProvider);
    final selectedFilter = ref.watch(journalCategoryFilterProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search patient, condition, invoice...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  ref.read(journalSearchQueryProvider.notifier).state = val;
                },
              )
            : const Text(
                'Journal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close Search' : 'Search Journal',
            onPressed: () {
              AppHaptics.light();
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  ref.read(journalSearchQueryProvider.notifier).state = '';
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Chips Row
          _buildFilterChips(context, ref, selectedFilter),

          const SizedBox(height: Spacing.xs),

          // Main Journal Feed
          Expanded(
            child: dayGroups.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: Spacing.md,
                      right: Spacing.md,
                      bottom: Spacing.xxl * 2,
                    ),
                    itemCount: dayGroups.length,
                    itemBuilder: (context, index) {
                      final group = dayGroups[index];
                      return _buildDateSection(context, group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    JournalEventType? currentFilter,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chips = [
      {'label': 'All Events', 'filter': null, 'icon': Icons.all_inclusive},
      {'label': 'Consultations', 'filter': JournalEventType.consultation, 'icon': Icons.medical_services_outlined},
      {'label': 'Dispenses', 'filter': JournalEventType.dispense, 'icon': Icons.medication_outlined},
      {'label': 'Expenses', 'filter': JournalEventType.expense, 'icon': Icons.receipt_long_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: Row(
        children: chips.map((c) {
          final isSelected = currentFilter == c['filter'];
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: FilterChip(
              avatar: Icon(
                c['icon'] as IconData,
                size: 16,
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              label: Text(c['label'] as String),
              selected: isSelected,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? scheme.onPrimary : scheme.onSurface,
              ),
              selectedColor: scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              onSelected: (selected) {
                AppHaptics.selection();
                ref.read(journalCategoryFilterProvider.notifier).state =
                    c['filter'] as JournalEventType?;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, JournalDayGroup group) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.md),

        // Section Header (Matching Google Fit: Date on left, aggregate stats on right)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm, horizontal: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.dayLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: scheme.onSurface,
                ),
              ),

              // Aggregate summary on right
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (group.totalRevenue > 0) ...[
                    Text(
                      Formatters.formatCurrency(group.totalRevenue),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                  ],
                  if (group.totalPatients > 0) ...[
                    Icon(
                      Icons.people_outline,
                      size: 15,
                      color: scheme.secondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${group.totalPatients}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.secondary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                  ],
                  // Concentric Double Activity Ring (Inner: Revenue Color1, Outer: Patient Color2)
                  DoubleActivityRing(
                    innerProgress: group.revenueProgress,
                    outerProgress: group.patientProgress,
                    innerColor: scheme.primary,
                    outerColor: scheme.secondary,
                    size: 22.0,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Entries for this date
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.entries.length,
          separatorBuilder: (context, i) => Divider(
            height: 1,
            indent: Spacing.md,
            endIndent: Spacing.md,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, i) {
            final entry = group.entries[i];
            return _buildJournalEntryCard(context, entry);
          },
        ),
      ],
    );
  }

  Widget _buildJournalEntryCard(BuildContext context, PracticeJournalEntry entry) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Resolve Category Visuals
    IconData miniIcon;
    IconData avatarIcon;
    Color avatarBg;
    Color avatarFg;

    switch (entry.type) {
      case JournalEventType.consultation:
        miniIcon = Icons.medical_services_outlined;
        avatarIcon = Icons.person_outline;
        avatarBg = scheme.secondary.withValues(alpha: 0.15);
        avatarFg = scheme.secondary;
        break;
      case JournalEventType.dispense:
        miniIcon = Icons.medication_outlined;
        avatarIcon = Icons.medication_outlined;
        avatarBg = scheme.primary.withValues(alpha: 0.15);
        avatarFg = scheme.primary;
        break;
      case JournalEventType.expense:
        miniIcon = Icons.receipt_long_outlined;
        avatarIcon = Icons.receipt_long_outlined;
        avatarBg = scheme.error.withValues(alpha: 0.15);
        avatarFg = scheme.error;
        break;
    }

    final timeStr = DateFormat('h:mm a').format(entry.timestamp);

    return InkWell(
      onTap: () {
        AppHaptics.light();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md, horizontal: Spacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top row: Mini Icon + Time
                  Row(
                    children: [
                      Icon(
                        miniIcon,
                        size: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // 2. Title Row (Bold)
                  Text(
                    entry.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // 3. Subtitle / Metadata Row (e.g. condition, payment method, amount)
                  Row(
                    children: [
                      if (entry.subtitle != null)
                        Flexible(
                          child: Text(
                            entry.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (entry.amount != null) ...[
                        if (entry.subtitle != null) ...[
                          const SizedBox(width: Spacing.xs),
                          Text('•', style: TextStyle(color: scheme.onSurfaceVariant)),
                          const SizedBox(width: Spacing.xs),
                        ],
                        Text(
                          entry.type == JournalEventType.expense
                              ? '-${Formatters.formatCurrency(entry.amount!)}'
                              : Formatters.formatCurrency(entry.amount!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: entry.type == JournalEventType.expense
                                ? scheme.error
                                : scheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: Spacing.md),

            // Right column: Circular Avatar Badge (Matching Google Fit walking icon circle)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
              ),
              child: Center(
                child: Icon(
                  avatarIcon,
                  size: 26,
                  color: avatarFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'No Journal Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Consultations, dispenses, and clinic expenses will appear here in chronological order.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
