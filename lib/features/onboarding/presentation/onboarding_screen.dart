import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/onboarding_provider.dart';

/// First-run setup: who the doctor is, and which clinics they run.
///
/// Two pages only. Everything asked here is something the app cannot work
/// without - a greeting needs a name, and a cash memo needs a clinic to
/// attribute revenue to. Anything else belongs in Settings, where it can be
/// changed later without a wizard.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();

  final _clinicNameControllers = <TextEditingController>[
    TextEditingController(),
  ];
  final _clinicAddressControllers = <TextEditingController>[
    TextEditingController(),
  ];

  double _revenueGoal = kDefaultRevenueGoal;
  int _patientGoal = kDefaultPatientGoal;

  late final TextEditingController _revenueController =
      TextEditingController(text: kDefaultRevenueGoal.round().toString());
  late final TextEditingController _patientController =
      TextEditingController(text: kDefaultPatientGoal.toString());

  int _page = 0;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _revenueController.dispose();
    _patientController.dispose();
    for (final c in _clinicNameControllers) {
      c.dispose();
    }
    for (final c in _clinicAddressControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canContinue {
    if (_page == 0) return _nameController.text.trim().isNotEmpty;
    return _clinicNameControllers.any((c) => c.text.trim().isNotEmpty);
  }

  void _addClinic() {
    setState(() {
      _clinicNameControllers.add(TextEditingController());
      _clinicAddressControllers.add(TextEditingController());
    });
  }

  void _removeClinic(int index) {
    setState(() {
      _clinicNameControllers.removeAt(index).dispose();
      _clinicAddressControllers.removeAt(index).dispose();
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final clinics = <DraftClinic>[];
    for (var i = 0; i < _clinicNameControllers.length; i++) {
      clinics.add(DraftClinic(
        name: _clinicNameControllers[i].text,
        address: _clinicAddressControllers[i].text,
      ));
    }

    await ref.read(onboardingControllerProvider).complete(
          doctorName: _nameController.text,
          clinics: clinics,
          revenueGoal: _revenueGoal,
          patientGoal: _patientGoal,
        );

    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 0 ? Spacing.sm : 0),
                        child: AnimatedContainer(
                          duration: Motion.base,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _page
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: Radii.pillAll,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _NamePage(controller: _nameController, onChanged: _refresh),
                  _ClinicsPage(
                    nameControllers: _clinicNameControllers,
                    addressControllers: _clinicAddressControllers,
                    revenueGoal: _revenueGoal,
                    patientGoal: _patientGoal,
                    revenueController: _revenueController,
                    patientController: _patientController,
                    onRevenueChanged: (v) => setState(() => _revenueGoal = v),
                    onPatientChanged: (v) => setState(() => _patientGoal = v),
                    onAddClinic: _addClinic,
                    onRemoveClinic: _removeClinic,
                    onChanged: _refresh,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => _pageController.previousPage(
                                duration: Motion.base,
                                curve: Motion.curve,
                              ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: !_canContinue || _saving
                        ? null
                        : () {
                            if (_page == 0) {
                              _pageController.nextPage(
                                duration: Motion.base,
                                curve: Motion.curve,
                              );
                            } else {
                              _finish();
                            }
                          },
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_page == 0 ? 'Continue' : 'Get started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refresh() => setState(() {});
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _NamePage({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      children: [
        const SizedBox(height: Spacing.xl),
        Text('Welcome to ClinicPilot',
            style: theme.textTheme.headlineMedium),
        const SizedBox(height: Spacing.sm),
        Text(
          'Know. Grow. Repeat.',
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: Spacing.xxl),
        Text(
          'What should the app call you?',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: Spacing.lg),
        CustomTextField(
          controller: controller,
          label: 'Your name',
          // A sample name reads as a real default and has to be cleared before
          // typing. The label already says what goes here.
          hint: '',
          prefixIcon: Icons.person_outline,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _ClinicsPage extends StatelessWidget {
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> addressControllers;
  final double revenueGoal;
  final int patientGoal;
  final TextEditingController revenueController;
  final TextEditingController patientController;
  final ValueChanged<double> onRevenueChanged;
  final ValueChanged<int> onPatientChanged;
  final VoidCallback onAddClinic;
  final ValueChanged<int> onRemoveClinic;
  final VoidCallback onChanged;

  const _ClinicsPage({
    required this.nameControllers,
    required this.addressControllers,
    required this.revenueGoal,
    required this.patientGoal,
    required this.revenueController,
    required this.patientController,
    required this.onRevenueChanged,
    required this.onPatientChanged,
    required this.onAddClinic,
    required this.onRemoveClinic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      children: [
        const SizedBox(height: Spacing.xl),
        Text('Your clinics', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          'Every patient, memo and expense belongs to a clinic, so the app can '
          'tell you which one is actually profitable.',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: Spacing.lg),

        for (var i = 0; i < nameControllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: nameControllers[i],
                  label: 'Clinic ${i + 1}',
                  hint: '',
                  prefixIcon: Icons.local_hospital_outlined,
                  onChanged: (_) => onChanged(),
                ),
              ),
              if (nameControllers.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.lg),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove',
                    onPressed: () => onRemoveClinic(i),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          CustomTextField(
            controller: addressControllers[i],
            label: 'Area (optional)',
            hint: '',
            prefixIcon: Icons.place_outlined,
          ),
          const SizedBox(height: Spacing.lg),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddClinic,
            icon: const Icon(Icons.add),
            label: const Text('Add another clinic'),
          ),
        ),

        const SizedBox(height: Spacing.xl),
        Text('Monthly goals', style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        Text(
          'The dashboard measures every month against these. They can be '
          'changed any time in Settings.',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: Spacing.lg),

        _GoalField(
          label: 'Revenue target',
          controller: revenueController,
          prefixIcon: Icons.currency_rupee,
          value: revenueGoal,
          min: kRevenueGoalMin,
          max: kRevenueGoalMax,
          divisions: 39,
          valueLabel: Formatters.formatCurrency(revenueGoal),
          onChanged: (v) {
            revenueController.text = v.round().toString();
            onRevenueChanged(v);
          },
          onTyped: (raw) {
            final parsed = double.tryParse(raw);
            if (parsed == null) return;
            onRevenueChanged(parsed.clamp(kRevenueGoalMin, kRevenueGoalMax));
          },
        ),
        const SizedBox(height: Spacing.xl),
        _GoalField(
          label: 'New patients target',
          controller: patientController,
          prefixIcon: Icons.person_add_outlined,
          value: patientGoal.toDouble(),
          min: kPatientGoalMin.toDouble(),
          max: kPatientGoalMax.toDouble(),
          divisions: kPatientGoalMax - kPatientGoalMin,
          valueLabel: '$patientGoal per month',
          onChanged: (v) {
            patientController.text = v.round().toString();
            onPatientChanged(v.round());
          },
          onTyped: (raw) {
            final parsed = int.tryParse(raw);
            if (parsed == null) return;
            onPatientChanged(parsed.clamp(kPatientGoalMin, kPatientGoalMax));
          },
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Number field with a slider beneath it.
///
/// Both edit the same value: the slider is fast for a rough figure, the field
/// is exact when the doctor already knows the number he wants.
class _GoalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;
  final ValueChanged<String> onTyped;

  const _GoalField({
    required this.label,
    required this.controller,
    required this.prefixIcon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
    required this.onTyped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          label: label,
          prefixIcon: prefixIcon,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onTyped,
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(left: Spacing.md),
          child: Text(valueLabel, style: theme.textTheme.labelMedium),
        ),
      ],
    );
  }
}
