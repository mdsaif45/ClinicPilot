import 'package:flutter/material.dart';
import '../../../../core/design/tokens.dart';
import '../../models/dental_chart_model.dart';

/// Callback when a tooth is tapped in the odontogram.
typedef OnToothTap = void Function(ToothData tooth);

/// An interactive, anatomical 32-tooth Odontogram chart.
///
/// Features:
/// - Maxillary (Upper) and Mandibular (Lower) anatomical arches.
/// - 4 Quadrants: Upper Right, Upper Left, Lower Right, Lower Left.
/// - Switchable FDI (11..48) and Universal (1..32) numbering systems.
/// - Color-coded status markers for Caries, Fillings, RCT, Crowns, Missing, Implants.
/// - Responsive, horizontally scrollable on mobile phones, spacious on tablets/desktops.
class OdontogramChartWidget extends StatelessWidget {
  final DentalChartData chartData;
  final OnToothTap onToothTap;
  final ValueChanged<DentalNotation>? onNotationChanged;

  const OdontogramChartWidget({
    super.key,
    required this.chartData,
    required this.onToothTap,
    this.onNotationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Toolbar: Notation Switcher & Arch Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: Spacing.xs),
                Text(
                  '32-TOOTH ODONTOGRAM',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            // Notation Toggle (FDI vs Universal)
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: Radii.pillAll,
                border: Border.all(color: scheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NotationPill(
                    label: 'FDI (11-48)',
                    isSelected: chartData.notation == DentalNotation.fdi,
                    onTap: () => onNotationChanged?.call(DentalNotation.fdi),
                  ),
                  _NotationPill(
                    label: 'Universal (1-32)',
                    isSelected: chartData.notation == DentalNotation.universal,
                    onTap:
                        () => onNotationChanged?.call(DentalNotation.universal),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),

        // Interactive Odontogram Card with Horizontal Scroll
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: Radii.mdAll,
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.md,
            horizontal: Spacing.sm,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 660,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper Arch Header
                  _ArchHeader(
                    title: 'UPPER JAW (MAXILLARY ARCH)',
                    leftQuadrantLabel: 'UR (Q1)',
                    rightQuadrantLabel: 'UL (Q2)',
                  ),
                  const SizedBox(height: Spacing.xs),

                  // Upper Teeth Row: UR (18..11) | UL (21..28)
                  Row(
                    children: [
                      // Quadrant 1: Upper Right
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              DentalNotationUtils.upperRightTeeth.map((fdi) {
                                final tooth =
                                    chartData.teeth[fdi] ??
                                    ToothData(fdiNumber: fdi);
                                return _ToothCell(
                                  tooth: tooth,
                                  notation: chartData.notation,
                                  isUpper: true,
                                  onTap: () => onToothTap(tooth),
                                );
                              }).toList(),
                        ),
                      ),

                      // Midline vertical divider
                      _MidlineDivider(label: 'MIDLINE'),

                      // Quadrant 2: Upper Left
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              DentalNotationUtils.upperLeftTeeth.map((fdi) {
                                final tooth =
                                    chartData.teeth[fdi] ??
                                    ToothData(fdiNumber: fdi);
                                return _ToothCell(
                                  tooth: tooth,
                                  notation: chartData.notation,
                                  isUpper: true,
                                  onTap: () => onToothTap(tooth),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),

                  // Occlusal Plane / Bite Line Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: scheme.outlineVariant,
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                          ),
                          child: Text(
                            'OCCLUSAL PLANE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: scheme.outlineVariant,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lower Teeth Row: LR (48..41) | LL (31..38)
                  Row(
                    children: [
                      // Quadrant 4: Lower Right
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              DentalNotationUtils.lowerRightTeeth.map((fdi) {
                                final tooth =
                                    chartData.teeth[fdi] ??
                                    ToothData(fdiNumber: fdi);
                                return _ToothCell(
                                  tooth: tooth,
                                  notation: chartData.notation,
                                  isUpper: false,
                                  onTap: () => onToothTap(tooth),
                                );
                              }).toList(),
                        ),
                      ),

                      // Midline vertical divider
                      _MidlineDivider(label: 'MIDLINE'),

                      // Quadrant 3: Lower Left
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              DentalNotationUtils.lowerLeftTeeth.map((fdi) {
                                final tooth =
                                    chartData.teeth[fdi] ??
                                    ToothData(fdiNumber: fdi);
                                return _ToothCell(
                                  tooth: tooth,
                                  notation: chartData.notation,
                                  isUpper: false,
                                  onTap: () => onToothTap(tooth),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),

                  // Lower Arch Footer
                  _ArchHeader(
                    title: 'LOWER JAW (MANDIBULAR ARCH)',
                    leftQuadrantLabel: 'LR (Q4)',
                    rightQuadrantLabel: 'LL (Q3)',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // Color-Coded Condition Legend
        _OdontogramLegend(),
      ],
    );
  }
}

class _NotationPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotationPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.pillAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: Radii.pillAll,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ArchHeader extends StatelessWidget {
  final String title;
  final String leftQuadrantLabel;
  final String rightQuadrantLabel;

  const _ArchHeader({
    required this.title,
    required this.leftQuadrantLabel,
    required this.rightQuadrantLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: Radii.smAll,
          ),
          child: Text(
            leftQuadrantLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: Radii.smAll,
          ),
          child: Text(
            rightQuadrantLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MidlineDivider extends StatelessWidget {
  final String label;

  const _MidlineDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 16,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 2, height: 26, color: scheme.primary),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.swap_horiz, size: 8, color: scheme.onPrimary),
          ),
          Container(width: 2, height: 26, color: scheme.primary),
        ],
      ),
    );
  }
}

/// An individual interactive tooth tile in the odontogram.
class _ToothCell extends StatelessWidget {
  final ToothData tooth;
  final DentalNotation notation;
  final bool isUpper;
  final VoidCallback onTap;

  const _ToothCell({
    required this.tooth,
    required this.notation,
    required this.isUpper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cond = tooth.condition;
    final displayNum = DentalNotationUtils.formatToothNumber(
      tooth.fdiNumber,
      notation,
    );
    final hasCondition = cond != ToothCondition.healthy;

    // Determine colors
    final badgeColor = cond.getBadgeColor(scheme);
    final containerColor = cond.getContainerColor(scheme);
    final isMissing = cond == ToothCondition.missing;

    final numberWidget = Text(
      displayNum,
      style: TextStyle(
        fontSize: 10,
        fontWeight: hasCondition ? FontWeight.bold : FontWeight.w500,
        color: hasCondition ? badgeColor : scheme.onSurfaceVariant,
      ),
    );

    return Tooltip(
      message:
          '${tooth.toothName} ($displayNum)\nStatus: ${cond.label}${tooth.surfacesSummary.isNotEmpty ? " (${tooth.surfacesSummary})" : ""}${tooth.notes.isNotEmpty ? "\nNotes: ${tooth.notes}" : ""}',
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.smAll,
        child: Container(
          width: 36,
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: isMissing ? Colors.transparent : containerColor,
            borderRadius: Radii.smAll,
            border: Border.all(
              color: hasCondition ? badgeColor : scheme.outlineVariant,
              width: hasCondition ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top label (Number for upper arch, surfaces for lower arch)
              if (isUpper)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: numberWidget,
                )
              else
                _buildSurfacesBadge(scheme),

              // Central Tooth Graphic / Glyph
              Expanded(
                child: Center(
                  child:
                      isMissing
                          ? Icon(Icons.close, size: 20, color: scheme.outline)
                          : cond == ToothCondition.healthy
                          ? Icon(
                            Icons.crop_square_rounded,
                            size: 16,
                            color: scheme.outlineVariant,
                          )
                          : Icon(cond.icon, size: 18, color: badgeColor),
                ),
              ),

              // Bottom label (Surfaces for upper arch, Number for lower arch)
              if (isUpper)
                _buildSurfacesBadge(scheme)
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: numberWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurfacesBadge(ColorScheme scheme) {
    if (tooth.surfacesSummary.isEmpty) {
      return const SizedBox(height: 12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Text(
        tooth.surfacesSummary,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: scheme.error,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Compact color-coded legend explaining dental status markers.
class _OdontogramLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final legendItems = [
      (ToothCondition.healthy, 'Healthy', scheme.outlineVariant),
      (ToothCondition.caries, 'Caries', scheme.error),
      (ToothCondition.filled, 'Filled', scheme.secondary),
      (ToothCondition.rootCanal, 'RCT', scheme.tertiary),
      (ToothCondition.crown, 'Crown', scheme.primary),
      (ToothCondition.missing, 'Missing', scheme.outline),
      (ToothCondition.implant, 'Implant', scheme.tertiary),
      (ToothCondition.impacted, 'Impacted', scheme.error),
    ];

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      alignment: WrapAlignment.center,
      children:
          legendItems.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
