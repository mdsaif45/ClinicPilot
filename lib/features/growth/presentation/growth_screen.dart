import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/tokens.dart';
import '../../../core/providers/period_provider.dart';
import '../../../core/services/list_export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/list_pdf_export_service.dart';
import '../../../core/widgets/export_action.dart';
import '../../../core/widgets/export_format_sheet.dart';
import '../../../core/widgets/period_selector.dart';
import '../providers/growth_provider.dart';

/// Growth has no row-level list to export - the provider already returns one
/// aggregated summary per period - so this is the same metric/value list
/// buildKeyValueCsv and buildKeyValueXlsx both expect, built once as a plain
/// function so the numbers are pinned in a test without touching the widget
/// tree, and shared between whichever format the doctor picks.
List<MapEntry<String, Object?>> growthExportEntries(GrowthAnalytics analytics) {
  return [
    MapEntry('New Patients', analytics.totalNewPatients),
    MapEntry('Repeat Patients', analytics.totalRepeatPatients),
    MapEntry('Total Patients', analytics.totalPatients),
    MapEntry('Repeat Rate (%)', analytics.repeatRate.toStringAsFixed(1)),
    MapEntry('Total Revenue', analytics.totalRevenue),
    MapEntry('Total Expenses', analytics.totalExpenses),
    MapEntry('Net Profit', analytics.netProfit),
    MapEntry(
      'Avg. Daily New Patients',
      analytics.avgDailyNewPatients.toStringAsFixed(1),
    ),
    MapEntry(
      'Avg. Daily Revenue',
      analytics.avgDailyRevenue.toStringAsFixed(2),
    ),
    MapEntry(
      'Avg. Revenue / Visit',
      analytics.avgRevenuePerVisit.toStringAsFixed(2),
    ),
    for (final e in analytics.referralSourceCount.entries)
      MapEntry('Referral: ${e.key}', e.value),
    for (final e in analytics.diseaseFrequency.entries)
      MapEntry('Disease: ${e.key}', e.value),
  ];
}

String growthExportTitle(DateTimeRange range) {
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  return 'Growth summary: ${fmt(range.start)} to ${fmt(range.end)}';
}

/// The same entries as [growthExportEntries], but with the three raw money
/// figures rendered "Rs. 1234.00" for the PDF - the font used there has no
/// Rupee glyph, and unlike CSV/XLSX a PDF is read, not recomputed in a
/// spreadsheet, so there is no reason to keep it a bare double.
List<MapEntry<String, Object?>> growthExportEntriesForPdf(
  GrowthAnalytics analytics,
) {
  String money(double v) => 'Rs. ${v.toStringAsFixed(2)}';
  return growthExportEntries(analytics).map((e) {
    return switch (e.key) {
      'Total Revenue' => MapEntry(e.key, money(analytics.totalRevenue)),
      'Total Expenses' => MapEntry(e.key, money(analytics.totalExpenses)),
      'Net Profit' => MapEntry(e.key, money(analytics.netProfit)),
      _ => e,
    };
  }).toList();
}

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  Future<void> _export(
    BuildContext context,
    GrowthAnalytics analytics,
    DateTimeRange range,
  ) async {
    final format = await pickExportFormat(context);
    if (format == null || !context.mounted) return;

    final entries = growthExportEntries(analytics);
    final title = growthExportTitle(range);
    final bytes = switch (format) {
      ExportFormat.csv => ListExportService.encodeCsv(
          ListExportService.buildKeyValueCsv(entries, title: title),
        ),
      ExportFormat.xlsx => ListExportService.buildKeyValueXlsx(
          entries,
          title: title,
          sheetName: 'Growth',
        ),
      ExportFormat.pdf => await ListPdfExportService.buildKeyValuePdf(
          title: title,
          entries: growthExportEntriesForPdf(analytics),
        ),
    };
    final extension = format.name;

    if (!context.mounted) return;
    await saveExportFile(
      context,
      bytes: bytes,
      fileName: ListExportService.suggestedFileName(
        'growth',
        DateTime.now(),
        extension: extension,
      ),
      extension: extension,
      rowCount: 1,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(growthAnalyticsProvider);
    final range = ref.watch(periodProvider).dateRange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onPressed: analyticsAsync.hasValue
                ? () => _export(context, analyticsAsync.value!, range)
                : null,
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The period control sits with the figures it scopes.
                const PeriodSelector(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'New Patients',
                        value: '${analytics.totalNewPatients}',
                        delta: analytics.newPatientGrowth,
                        tone: _Tone.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Repeat Patients',
                        value: '${analytics.totalRepeatPatients}',
                        delta: analytics.repeatPatientGrowth,
                        tone: _Tone.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Total Patients',
                        value: '${analytics.totalPatients}',
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Repeat Rate',
                        value: '${analytics.repeatRate.toStringAsFixed(1)}%',
                        tone: _Tone.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),

                // Patient count per day, distinct from the money trend below.
                Text('Patient Growth Trend',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    _buildPatientChartData(context, analytics.dailyPatientMap),
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                Text('Quick Stats',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Daily New Patients',
                        value:
                            analytics.avgDailyNewPatients.toStringAsFixed(1),
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Daily Revenue',
                        value: Formatters.formatCurrency(
                            analytics.avgDailyRevenue),
                        tone: _Tone.neutral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Revenue / Visit',
                        value: Formatters.formatCurrency(
                            analytics.avgRevenuePerVisit),
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Net Profit',
                        value: Formatters.formatCurrency(analytics.netProfit),
                        tone: analytics.netProfit < 0
                            ? _Tone.negative
                            : _Tone.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),

                // Financial Trend Line Chart Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.mdAll,
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Revenue vs Expenses Trend',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Income',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(width: Spacing.md),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Expenses',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.lg),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            _buildLineChartData(context,
                                analytics.dailyRevenueMap, analytics.dailyExpenseMap),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                // Referral Sources Distribution
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.mdAll,
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Referral Source Distribution',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: Spacing.lg),
                        if (analytics.referralSourceCount.isEmpty)
                          const Center(child: Text('No referral data available.'))
                        else
                          Column(
                            children: analytics.referralSourceCount.entries.map((e) {
                              final total = analytics.referralSourceCount.values
                                   .fold(0, (a, b) => a + b);
                              final pct = total > 0 ? e.value / total : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: Spacing.sm),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(e.key),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: Spacing.sm),
                                    Text('${(pct * 100).toStringAsFixed(0)}%'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xxl + 48),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  /// Visits per day. Kept separate from the money chart so a busy day is not
  /// confused with a profitable one.
  LineChartData _buildPatientChartData(
      BuildContext context, Map<int, int> dailyPatients) {
    final scheme = Theme.of(context).colorScheme;
    final spots = dailyPatients.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Whole-number axis: half a patient is not a thing.
    final maxY = spots.isEmpty
        ? 4.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1;

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => scheme.inverseSurface,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
            return LineTooltipItem(
              'Day ${s.x.toInt()}: ${s.y.toInt()} patients',
              TextStyle(
                color: scheme.onInverseSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 5,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots.isEmpty ? [const FlSpot(1, 0)] : spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: scheme.tertiary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: scheme.tertiary,
              strokeWidth: 2,
              strokeColor: scheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.tertiary.withValues(alpha: 0.25),
                scheme.tertiary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(BuildContext context,
      Map<int, double> revenueMap, Map<int, double> expenseMap) {
    final scheme = Theme.of(context).colorScheme;
    final revenueSpots = revenueMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final expenseSpots = expenseMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final allValues = [
      ...revenueSpots.map((s) => s.y),
      ...expenseSpots.map((s) => s.y),
    ];
    final maxY = allValues.isEmpty
        ? 1000.0
        : (allValues.reduce((a, b) => a > b ? a : b) * 1.15);

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => scheme.inverseSurface,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
            final isRevenue = s.barIndex == 0;
            return LineTooltipItem(
              '${isRevenue ? "Income: " : "Expense: "}${Formatters.formatCurrency(s.y)}',
              TextStyle(
                color: isRevenue ? scheme.primaryContainer : scheme.errorContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: maxY <= 1000 ? 500 : (maxY / 4).ceilToDouble(),
            getTitlesWidget: (v, _) {
              if (v == 0) return Text('0', style: Theme.of(context).textTheme.labelSmall);
              final k = v >= 1000
                  ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
                  : v.toInt().toString();
              return Text(
                '₹$k',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 5,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: revenueSpots.isEmpty ? [const FlSpot(1, 0)] : revenueSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: scheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: scheme.primary,
              strokeWidth: 2,
              strokeColor: scheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.primary.withValues(alpha: 0.2),
                scheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: expenseSpots.isEmpty ? [const FlSpot(1, 0)] : expenseSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: scheme.error,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: scheme.error,
              strokeWidth: 2,
              strokeColor: scheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.error.withValues(alpha: 0.15),
                scheme.error.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _Tone { primary, tertiary, neutral, negative }

/// Metric tile with an optional period-over-period delta badge.
class _GrowthTile extends StatelessWidget {
  final String label;
  final String value;
  final double? delta;
  final _Tone tone;

  const _GrowthTile({
    required this.label,
    required this.value,
    required this.tone,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (fg, bg) = switch (tone) {
      _Tone.primary => (scheme.primary, scheme.primaryContainer),
      _Tone.tertiary => (scheme.tertiary, scheme.tertiaryContainer),
      _Tone.negative => (scheme.error, scheme.errorContainer),
      _Tone.neutral => (scheme.onSurface, scheme.surfaceContainerHighest),
    };

    final d = delta;
    final rising = (d ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (d != null) ...[
                const SizedBox(width: Spacing.xs),
                Icon(
                  rising ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: rising ? scheme.primary : scheme.error,
                ),
                Text(
                  '${d.abs().toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: rising ? scheme.primary : scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
