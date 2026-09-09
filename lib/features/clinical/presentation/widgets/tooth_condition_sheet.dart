import 'package:flutter/material.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/dental_chart_model.dart';

/// Interactive modal sheet to view and update the clinical state, surfaces,
/// and notes for an individual tooth.
class ToothConditionSheet extends StatefulWidget {
  final ToothData tooth;
  final DentalNotation notation;
  final ValueChanged<ToothData> onSave;
  final VoidCallback? onAddProcedure;

  const ToothConditionSheet({
    super.key,
    required this.tooth,
    required this.notation,
    required this.onSave,
    this.onAddProcedure,
  });

  static Future<ToothData?> show({
    required BuildContext context,
    required ToothData tooth,
    required DentalNotation notation,
    VoidCallback? onAddProcedure,
  }) {
    return showModalBottomSheet<ToothData>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => ToothConditionSheet(
            tooth: tooth,
            notation: notation,
            onSave: (updated) => Navigator.of(ctx).pop(updated),
            onAddProcedure: onAddProcedure,
          ),
    );
  }

  @override
  State<ToothConditionSheet> createState() => _ToothConditionSheetState();
}

class _ToothConditionSheetState extends State<ToothConditionSheet> {
  late ToothCondition _condition;
  late Set<ToothSurface> _surfaces;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _condition = widget.tooth.condition;
    _surfaces = Set<ToothSurface>.from(widget.tooth.affectedSurfaces);
    _notesController = TextEditingController(text: widget.tooth.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleSurface(ToothSurface surface) {
    setState(() {
      if (_surfaces.contains(surface)) {
        _surfaces.remove(surface);
      } else {
        _surfaces.add(surface);
      }
    });
  }

  void _selectCondition(ToothCondition cond) {
    setState(() {
      _condition = cond;
      // If reset to healthy or missing, clear surfaces
      if (cond == ToothCondition.healthy ||
          cond == ToothCondition.missing ||
          cond == ToothCondition.implant) {
        _surfaces.clear();
      }
    });
  }

  void _applyQuickPreset(String code) {
    setState(() {
      _surfaces.clear();
      if (code == 'O') {
        _surfaces.add(ToothSurface.occlusal);
      } else if (code == 'MO') {
        _surfaces.addAll([ToothSurface.mesial, ToothSurface.occlusal]);
      } else if (code == 'DO') {
        _surfaces.addAll([ToothSurface.distal, ToothSurface.occlusal]);
      } else if (code == 'MOD') {
        _surfaces.addAll([
          ToothSurface.mesial,
          ToothSurface.occlusal,
          ToothSurface.distal,
        ]);
      } else if (code == 'ALL') {
        _surfaces.addAll(ToothSurface.values);
      }
    });
  }

  void _handleSave() {
    final updated = widget.tooth.copyWith(
      condition: _condition,
      affectedSurfaces: _surfaces,
      notes: _notesController.text.trim(),
    );
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fdi = widget.tooth.fdiNumber;
    final univ = widget.tooth.universalNumber;
    final displayNum = DentalNotationUtils.formatToothNumber(
      fdi,
      widget.notation,
    );
    final toothName = widget.tooth.toothName;
    final quadName = widget.tooth.quadrantName;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.lg),
        ),
      ),
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: Radii.pillAll,
                ),
              ),
            ),

            // Header with Tooth info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _condition.getContainerColor(scheme),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _condition.getBadgeColor(scheme),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayNum,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        toothName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'FDI: $fdi • Univ: #$univ • $quadName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // Condition Selection Header
            Text(
              'CLINICAL DIAGNOSIS / CONDITION',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),

            // Condition Chips Wrap
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children:
                  ToothCondition.values.map((cond) {
                    final isSelected = _condition == cond;
                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        cond.icon,
                        size: 16,
                        color:
                            isSelected
                                ? scheme.onPrimary
                                : cond.getBadgeColor(scheme),
                      ),
                      label: Text(cond.label),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? scheme.onPrimary : scheme.onSurface,
                      ),
                      selectedColor: scheme.primary,
                      backgroundColor: scheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: Radii.smAll,
                        side: BorderSide(
                          color:
                              isSelected
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                        ),
                      ),
                      onSelected: (_) => _selectCondition(cond),
                    );
                  }).toList(),
            ),
            const SizedBox(height: Spacing.lg),

            // Surface Selector (shown for Caries and Filled)
            if (_condition == ToothCondition.caries ||
                _condition == ToothCondition.filled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AFFECTED SURFACES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (_surfaces.isNotEmpty)
                    Text(
                      'Selected: ${_surfaces.map((s) => s.code).join()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.xs),

              // Surface Pills
              Row(
                children:
                    ToothSurface.values.map((surface) {
                      final isSelected = _surfaces.contains(surface);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () => _toggleSurface(surface),
                            borderRadius: Radii.smAll,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? scheme.primaryContainer
                                        : scheme.surfaceContainerHighest,
                                borderRadius: Radii.smAll,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? scheme.primary
                                          : scheme.outlineVariant,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    surface.code,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color:
                                          isSelected
                                              ? scheme.primary
                                              : scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    surface.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color:
                                          isSelected
                                              ? scheme.primary
                                              : scheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: Spacing.xs),

              // Quick presets (O, MO, DO, MOD, All)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Presets: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  for (final p in ['O', 'MO', 'DO', 'MOD', 'ALL'])
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: InkWell(
                        onTap: () => _applyQuickPreset(p),
                        borderRadius: Radii.smAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: Radii.smAll,
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
            ],

            // Clinical Notes for this Tooth
            Text(
              'TOOTH OBSERVATIONS / CLINICAL NOTES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText:
                    'e.g., Deep occlusal fissure, tender on percussion, grade 1 mobility...',
                border: OutlineInputBorder(borderRadius: Radii.smAll),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: Spacing.lg),

            // Action Buttons
            Row(
              children: [
                if (widget.onAddProcedure != null) ...[
                  Expanded(
                    child: AppButton.outlined(
                      label: 'Add Procedure',
                      icon: Icons.add_circle_outline,
                      onPressed: () {
                        _handleSave();
                        widget.onAddProcedure?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                ],
                Expanded(
                  child: AppButton.primary(
                    label: 'Save Changes',
                    icon: Icons.check,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
