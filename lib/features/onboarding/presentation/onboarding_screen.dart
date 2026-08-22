import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/sample_data_seeder.dart';
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
  final _nameFocus = FocusNode();

  final _clinicNameControllers = <TextEditingController>[
    TextEditingController(),
  ];
  final _clinicAddressControllers = <TextEditingController>[
    TextEditingController(),
  ];
  final _clinicNameFocus = FocusNode();
  final _areaFocus = FocusNode();
  final _revenueFocus = FocusNode();
  final _patientFocus = FocusNode();

  double _revenueGoal = kDefaultRevenueGoal;
  int _patientGoal = kDefaultPatientGoal;

  late final TextEditingController _revenueController =
      TextEditingController(text: kDefaultRevenueGoal.round().toString());
  late final TextEditingController _patientController =
      TextEditingController(text: kDefaultPatientGoal.toString());

  int _page = 0;
  bool _saving = false;

  // The clinics page is already built (PageView builds both up front), so
  // autofocus:true on its field would fire before the page is ever shown.
  // This flags "the doctor has just arrived here", set once on the page
  // transition, and is not re-armed by Back so returning to page 1 and
  // forward again does not steal focus a second time.
  bool _focusClinicsPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _revenueController.dispose();
    _patientController.dispose();
    _clinicNameFocus.dispose();
    _areaFocus.dispose();
    _revenueFocus.dispose();
    _patientFocus.dispose();
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

  Future<void> _loadSampleData() async {
    setState(() => _saving = true);
    await SampleDataSeeder.seedRealisticData(ref);
    AppHaptics.success();
    if (mounted) context.go('/dashboard');
  }

  @override
  void initState() {
    super.initState();
    // Page 1 is visible immediately at build time, so this is safe as a
    // direct request rather than needing the same post-transition dance as
    // the clinics page below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
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
                            borderRadius: Radii.smAll,
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
                onPageChanged: (i) {
                  setState(() => _page = i);
                  if (i == 1 && !_focusClinicsPage) {
                    setState(() => _focusClinicsPage = true);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _clinicNameFocus.requestFocus();
                    });
                  }
                },
                children: [
                  _NamePage(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    onChanged: _refresh,
                    onDemoSelected: _saving ? null : _loadSampleData,
                    onSubmitted: () {
                      // Matches the Continue button's own guard - Enter must
                      // not advance past an empty name any more than a tap
                      // would.
                      if (!_canContinue) return;
                      _pageController.nextPage(
                        duration: Motion.base,
                        curve: Motion.curve,
                      );
                    },
                  ),
                  _ClinicsPage(
                    nameControllers: _clinicNameControllers,
                    addressControllers: _clinicAddressControllers,
                    firstNameFocus: _clinicNameFocus,
                    firstAreaFocus: _areaFocus,
                    revenueFocus: _revenueFocus,
                    patientFocus: _patientFocus,
                    revenueGoal: _revenueGoal,
                    patientGoal: _patientGoal,
                    revenueController: _revenueController,
                    patientController: _patientController,
                    onRevenueChanged: (v) => setState(() => _revenueGoal = v),
                    onPatientChanged: (v) => setState(() => _patientGoal = v),
                    onAddClinic: _addClinic,
                    onRemoveClinic: _removeClinic,
                    onChanged: _refresh,
                    onSubmitted: () {
                      if (_canContinue && !_saving) _finish();
                    },
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
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback? onDemoSelected;

  const _NamePage({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.onDemoSelected,
  });

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
          focusNode: focusNode,
          autofocus: true,
          textInputAction: TextInputAction.next,
          // Matches what tapping Continue does, so the keyboard's own action
          // key is not a dead end next to a button that works.
          onFieldSubmitted: (_) => onSubmitted(),
        ),
        if (onDemoSelected != null) ...[
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            onPressed: onDemoSelected,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Explore with Sample Practice Data'),
          ),
        ],
      ],
    );
  }
}

class _ClinicsPage extends StatelessWidget {
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> addressControllers;
  final FocusNode firstNameFocus;
  final FocusNode firstAreaFocus;
  final FocusNode revenueFocus;
  final FocusNode patientFocus;
  final double revenueGoal;
  final int patientGoal;
  final TextEditingController revenueController;
  final TextEditingController patientController;
  final ValueChanged<double> onRevenueChanged;
  final ValueChanged<int> onPatientChanged;
  final VoidCallback onAddClinic;
  final ValueChanged<int> onRemoveClinic;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _ClinicsPage({
    required this.nameControllers,
    required this.addressControllers,
    required this.firstNameFocus,
    required this.firstAreaFocus,
    required this.revenueFocus,
    required this.patientFocus,
    required this.revenueGoal,
    required this.patientGoal,
    required this.revenueController,
    required this.patientController,
    required this.onRevenueChanged,
    required this.onPatientChanged,
    required this.onAddClinic,
    required this.onRemoveClinic,
    required this.onChanged,
    required this.onSubmitted,
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
                  // Only clinic 1 carries the node the page hands autofocus
                  // to; clinic 2+ come from "Add another clinic" and are
                  // never the page's first field.
                  focusNode: i == 0 ? firstNameFocus : null,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: i == 0
                      ? (_) => firstAreaFocus.requestFocus()
                      : null,
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
            focusNode: i == 0 ? firstAreaFocus : null,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: i == 0
                ? (_) => revenueFocus.requestFocus()
                : null,
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
          focusNode: revenueFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: () => patientFocus.requestFocus(),
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
          focusNode: patientFocus,
          // Last field on the page: Enter here does what "Get started" does.
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onSubmitted,
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
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;

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
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
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
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted == null
              ? null
              : (_) => onFieldSubmitted!(),
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
