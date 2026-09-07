import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../models/soap_note_model.dart';

/// Interactive and touch-friendly card for recording and displaying patient Vital Signs.
class VitalSignsCard extends StatefulWidget {
  final TextEditingController bpController;
  final TextEditingController pulseController;
  final TextEditingController tempController;
  final TextEditingController spo2Controller;
  final TextEditingController respRateController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController sugarController;
  final VoidCallback? onChanged;

  const VitalSignsCard({
    super.key,
    required this.bpController,
    required this.pulseController,
    required this.tempController,
    required this.spo2Controller,
    required this.respRateController,
    required this.weightController,
    required this.heightController,
    required this.sugarController,
    this.onChanged,
  });

  @override
  State<VitalSignsCard> createState() => _VitalSignsCardState();
}

class _VitalSignsCardState extends State<VitalSignsCard> {
  String _calculatedBmi = '';
  String _bmiCategory = '';

  @override
  void initState() {
    super.initState();
    _recalculateBmi();
    widget.weightController.addListener(_onDimensionsChanged);
    widget.heightController.addListener(_onDimensionsChanged);
  }

  @override
  void dispose() {
    widget.weightController.removeListener(_onDimensionsChanged);
    widget.heightController.removeListener(_onDimensionsChanged);
    super.dispose();
  }

  void _onDimensionsChanged() {
    _recalculateBmi();
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  void _recalculateBmi() {
    _calculatedBmi = VitalSigns.calculateBmi(
      widget.weightController.text,
      widget.heightController.text,
    );
    if (_calculatedBmi.isNotEmpty) {
      final vs = VitalSigns(bmi: _calculatedBmi);
      _bmiCategory = vs.bmiCategory;
    } else {
      _bmiCategory = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_outlined,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Vital Signs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_calculatedBmi.isNotEmpty)
                CustomBadge(
                  label: 'BMI: $_calculatedBmi ($_bmiCategory)',
                  color: scheme.primary,
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Row 1: Blood Pressure & Pulse
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.bpController,
                  label: 'Blood Pressure',
                  hint: 'e.g. 120/80',
                  prefixIcon: Icons.speed_outlined,
                  keyboardType: TextInputType.text,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: widget.pulseController,
                  label: 'Pulse (bpm)',
                  hint: 'e.g. 72',
                  prefixIcon: Icons.favorite_outline,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Row 2: Temperature & SpO2
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.tempController,
                  label: 'Temperature (°F)',
                  hint: 'e.g. 98.6',
                  prefixIcon: Icons.thermostat_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: widget.spo2Controller,
                  label: 'SpO2 (%)',
                  hint: 'e.g. 99',
                  prefixIcon: Icons.air_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Row 3: Weight & Height
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.weightController,
                  label: 'Weight (kg)',
                  hint: 'e.g. 68',
                  prefixIcon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: widget.heightController,
                  label: 'Height (cm)',
                  hint: 'e.g. 172',
                  prefixIcon: Icons.height_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Row 4: Blood Sugar & Respiratory Rate
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.sugarController,
                  label: 'Blood Sugar (mg/dL)',
                  hint: 'e.g. 110 (RBS)',
                  prefixIcon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.text,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: widget.respRateController,
                  label: 'Resp. Rate (/min)',
                  hint: 'e.g. 16',
                  prefixIcon: Icons.air,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => widget.onChanged?.call(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only visual strip displaying patient vital signs.
class VitalSignsSummaryStrip extends StatelessWidget {
  final VitalSigns vitals;

  const VitalSignsSummaryStrip({super.key, required this.vitals});

  @override
  Widget build(BuildContext context) {
    if (!vitals.isNotEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chips = <Widget>[];

    if (vitals.bloodPressure.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.speed_outlined,
          'BP',
          '${vitals.bloodPressure} mmHg',
        ),
      );
    }
    if (vitals.pulse.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.favorite_outline,
          'Pulse',
          '${vitals.pulse} bpm',
        ),
      );
    }
    if (vitals.temperature.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.thermostat_outlined,
          'Temp',
          '${vitals.temperature}°F',
        ),
      );
    }
    if (vitals.spo2.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(scheme, Icons.air_outlined, 'SpO2', '${vitals.spo2}%'),
      );
    }
    if (vitals.weightKg.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.monitor_weight_outlined,
          'Wt',
          '${vitals.weightKg} kg',
        ),
      );
    }
    if (vitals.bmi.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.accessibility_new_outlined,
          'BMI',
          vitals.bmi,
        ),
      );
    }
    if (vitals.bloodSugar.trim().isNotEmpty) {
      chips.add(
        _buildVitalChip(
          scheme,
          Icons.water_drop_outlined,
          'Sugar',
          vitals.bloodSugar,
        ),
      );
    }

    return Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: chips);
  }

  Widget _buildVitalChip(
    ColorScheme scheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: Radii.smAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
