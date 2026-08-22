import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/sample_data_seeder.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/day_selector_field.dart';
import '../providers/onboarding_provider.dart';

/// First-run setup: who the doctor is, and their clinic details.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _ClinicFormControllers {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController rentController;
  final TextEditingController feeController;
  final TextEditingController revGoalController;
  final TextEditingController patGoalController;
  String openDays;

  _ClinicFormControllers()
      : nameController = TextEditingController(),
        addressController = TextEditingController(),
        phoneController = TextEditingController(),
        rentController = TextEditingController(text: '5000'),
        feeController = TextEditingController(text: '300'),
        revGoalController = TextEditingController(text: '30000'),
        patGoalController = TextEditingController(text: '10'),
        openDays = '1,2,3,4,5,6';

  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    rentController.dispose();
    feeController.dispose();
    revGoalController.dispose();
    patGoalController.dispose();
  }

  DraftClinic toDraft() {
    return DraftClinic(
      name: nameController.text,
      address: addressController.text,
      phone: phoneController.text,
      rent: double.tryParse(rentController.text) ?? 5000,
      consultationFee: double.tryParse(feeController.text) ?? 300,
      openDays: openDays,
      revenueGoal: double.tryParse(revGoalController.text) ?? 30000,
      patientGoal: int.tryParse(patGoalController.text) ?? 10,
    );
  }
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  final _clinics = <_ClinicFormControllers>[
    _ClinicFormControllers(),
  ];

  final _clinicNameFocus = FocusNode();
  final _areaFocus = FocusNode();

  int _page = 0;
  bool _saving = false;
  bool _focusClinicsPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _clinicNameFocus.dispose();
    _areaFocus.dispose();
    for (final c in _clinics) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canContinue {
    if (_page == 0) return _nameController.text.trim().isNotEmpty;
    return _clinics.any((c) => c.nameController.text.trim().isNotEmpty);
  }

  void _addClinic() {
    setState(() {
      _clinics.add(_ClinicFormControllers());
    });
  }

  void _removeClinic(int index) {
    setState(() {
      _clinics.removeAt(index).dispose();
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final draftClinics = _clinics.map((c) => c.toDraft()).toList();

    await ref.read(onboardingControllerProvider).complete(
          doctorName: _nameController.text,
          clinics: draftClinics,
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
                      if (!_canContinue) return;
                      _pageController.nextPage(
                        duration: Motion.base,
                        curve: Motion.curve,
                      );
                    },
                  ),
                  _ClinicsPage(
                    clinics: _clinics,
                    firstNameFocus: _clinicNameFocus,
                    firstAreaFocus: _areaFocus,
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
          hint: 'e.g. Dr. Md. Saifuddin',
          prefixIcon: Icons.person_outline,
          onChanged: (_) => onChanged(),
          focusNode: focusNode,
          autofocus: true,
          textInputAction: TextInputAction.next,
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
  final List<_ClinicFormControllers> clinics;
  final FocusNode firstNameFocus;
  final FocusNode firstAreaFocus;
  final VoidCallback onAddClinic;
  final ValueChanged<int> onRemoveClinic;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _ClinicsPage({
    required this.clinics,
    required this.firstNameFocus,
    required this.firstAreaFocus,
    required this.onAddClinic,
    required this.onRemoveClinic,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      children: [
        const SizedBox(height: Spacing.xl),
        Text('Your clinics', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          'Set up your clinic profile, fees, open days, and monthly targets. '
          'You can change these anytime in Settings.',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: Spacing.lg),

        for (var i = 0; i < clinics.length; i++) ...[
          Card(
            elevation: 0,
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: Radii.mdAll,
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: scheme.primary, size: 20),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Clinic ${i + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (clinics.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Remove',
                          onPressed: () => onRemoveClinic(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  CustomTextField(
                    controller: clinics[i].nameController,
                    label: 'Clinic Name *',
                    hint: 'e.g. City Care Homeopathy',
                    prefixIcon: Icons.business_outlined,
                    onChanged: (_) => onChanged(),
                    focusNode: i == 0 ? firstNameFocus : null,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: i == 0
                        ? (_) => firstAreaFocus.requestFocus()
                        : null,
                  ),
                  const SizedBox(height: Spacing.sm),
                  CustomTextField(
                    controller: clinics[i].addressController,
                    label: 'Address / Location (Optional)',
                    hint: 'e.g. Main Market, City Center',
                    prefixIcon: Icons.place_outlined,
                    focusNode: i == 0 ? firstAreaFocus : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Spacing.sm),
                  CustomTextField(
                    controller: clinics[i].phoneController,
                    label: 'Phone Number (Optional)',
                    hint: 'e.g. +91 98765 43210',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: clinics[i].rentController,
                          label: 'Fixed Rent (₹)',
                          hint: '5000',
                          prefixIcon: Icons.home_work_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: CustomTextField(
                          controller: clinics[i].feeController,
                          label: 'Consultation Fee (₹)',
                          hint: '300',
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  DaySelectorField(
                    label: 'Open Days',
                    value: clinics[i].openDays,
                    onChanged: (v) {
                      clinics[i].openDays = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: clinics[i].revGoalController,
                          label: 'Monthly Revenue Goal (₹)',
                          hint: '30000',
                          prefixIcon: Icons.trending_up,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: CustomTextField(
                          controller: clinics[i].patGoalController,
                          label: 'Monthly New Patients',
                          hint: '10',
                          prefixIcon: Icons.person_add_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => onSubmitted(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddClinic,
            icon: const Icon(Icons.add),
            label: const Text('Add another clinic'),
          ),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}
