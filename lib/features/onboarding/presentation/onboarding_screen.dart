import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/day_selector_field.dart';
import '../providers/onboarding_provider.dart';

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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _firstNameController = TextEditingController(text: 'Dr. ');
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _regNumberController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _qualificationFocus = FocusNode();
  final _regNumberFocus = FocusNode();

  final _clinics = <_ClinicFormControllers>[_ClinicFormControllers()];

  final _clinicNameFocus = FocusNode();
  final _areaFocus = FocusNode();

  int _page = 0;
  bool _saving = false;
  bool _hasVisitedDetails = false;
  bool _hasVisitedClinics = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _regNumberController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _qualificationFocus.dispose();
    _regNumberFocus.dispose();

    _clinicNameFocus.dispose();
    _areaFocus.dispose();
    for (final c in _clinics) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canContinue {
    if (_page == 0) {
      final fn = _firstNameController.text.trim();
      final ln = _lastNameController.text.trim();
      final hasFn =
          fn.isNotEmpty &&
          fn.toLowerCase() != 'dr.' &&
          fn.toLowerCase() != 'dr' &&
          fn.toLowerCase() != 'dr. ';
      final hasLn = ln.isNotEmpty;
      return hasFn && hasLn;
    }
    if (_page == 1) {
      return true;
    }
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

    await ref
        .read(onboardingControllerProvider)
        .complete(
          doctorFirstName: _firstNameController.text.trim(),
          doctorLastName: _lastNameController.text.trim(),
          doctorEmail: _emailController.text.trim(),
          doctorPhone: _phoneController.text.trim(),
          doctorQualification: _qualificationController.text.trim(),
          doctorRegNumber: _regNumberController.text.trim(),
          clinics: draftClinics,
        );

    if (mounted) context.go('/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _firstNameController.text.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _firstNameFocus.requestFocus();
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
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? Spacing.sm : 0),
                        child: AnimatedContainer(
                          duration: Motion.base,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                i <= _page
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
                onPageChanged: (p) {
                  setState(() => _page = p);
                  if (p == 1 && !_hasVisitedDetails) {
                    _hasVisitedDetails = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _qualificationFocus.requestFocus();
                    });
                  } else if (p == 2 && !_hasVisitedClinics) {
                    _hasVisitedClinics = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _clinicNameFocus.requestFocus();
                    });
                  }
                },
                children: [
                  _DoctorNamePage(
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    firstNameFocus: _firstNameFocus,
                    lastNameFocus: _lastNameFocus,
                    onChanged: _refresh,
                    onSubmitted: () {
                      if (_canContinue) {
                        _pageController.nextPage(
                          duration: Motion.base,
                          curve: Motion.curve,
                        );
                      }
                    },
                  ),
                  _DoctorDetailsPage(
                    qualificationController: _qualificationController,
                    regNumberController: _regNumberController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    qualificationFocus: _qualificationFocus,
                    regNumberFocus: _regNumberFocus,
                    phoneFocus: _phoneFocus,
                    emailFocus: _emailFocus,
                    onChanged: _refresh,
                    onSubmitted: () {
                      if (_canContinue) {
                        _pageController.nextPage(
                          duration: Motion.base,
                          curve: Motion.curve,
                        );
                      }
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
                    AppButton.text(
                      label: 'Back',
                      onPressed:
                          _saving
                              ? null
                              : () => _pageController.previousPage(
                                duration: Motion.base,
                                curve: Motion.curve,
                              ),
                    ),
                  const Spacer(),
                  AppButton.primary(
                    label: _page < 2 ? 'Continue' : 'Get started',
                    loading: _saving,
                    onPressed:
                        !_canContinue || _saving
                            ? null
                            : () {
                              if (_page < 2) {
                                _pageController.nextPage(
                                  duration: Motion.base,
                                  curve: Motion.curve,
                                );
                              } else {
                                _finish();
                              }
                            },
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

class _DoctorNamePage extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final FocusNode firstNameFocus;
  final FocusNode lastNameFocus;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _DoctorNamePage({
    required this.firstNameController,
    required this.lastNameController,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.xxl,
      ),
      children: [
        const SizedBox(height: Spacing.sm),
        Text('Welcome to ClinicPilot', style: theme.textTheme.headlineMedium),
        const SizedBox(height: Spacing.xs),
        Text(
          'Know. Grow. Repeat.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          'What is your name?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Your profile information is stored safely on this device.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        CustomTextField(
          controller: firstNameController,
          label: 'First Name *',
          prefixIcon: Icons.person_outline,
          onChanged: (_) => onChanged(),
          focusNode: firstNameFocus,
          autofocus: true,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => lastNameFocus.requestFocus(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: lastNameController,
          label: 'Last Name *',
          prefixIcon: Icons.person_outline,
          onChanged: (_) => onChanged(),
          focusNode: lastNameFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }
}

class _DoctorDetailsPage extends StatelessWidget {
  final TextEditingController qualificationController;
  final TextEditingController regNumberController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  final FocusNode qualificationFocus;
  final FocusNode regNumberFocus;
  final FocusNode phoneFocus;
  final FocusNode emailFocus;

  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _DoctorDetailsPage({
    required this.qualificationController,
    required this.regNumberController,
    required this.phoneController,
    required this.emailController,
    required this.qualificationFocus,
    required this.regNumberFocus,
    required this.phoneFocus,
    required this.emailFocus,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.xxl,
      ),
      children: [
        const SizedBox(height: Spacing.sm),
        Text('Doctor Credentials', style: theme.textTheme.headlineMedium),
        const SizedBox(height: Spacing.xs),
        Text(
          'Qualifications & Contact',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          'Professional Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'These details appear on your printed prescriptions and receipts.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        CustomTextField(
          controller: qualificationController,
          label: 'Qualifications / Degrees',
          hint: 'e.g. MBBS, MD, BHMS',
          prefixIcon: Icons.school_outlined,
          onChanged: (_) => onChanged(),
          focusNode: qualificationFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => regNumberFocus.requestFocus(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: regNumberController,
          label: 'Registration No.',
          hint: 'e.g. WBMC-12345',
          prefixIcon: Icons.badge_outlined,
          onChanged: (_) => onChanged(),
          focusNode: regNumberFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => phoneFocus.requestFocus(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: phoneController,
          label: 'Phone Number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (_) => onChanged(),
          focusNode: phoneFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => emailFocus.requestFocus(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: emailController,
          label: 'Email Address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => onChanged(),
          focusNode: emailFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.xxl,
      ),
      children: [
        const SizedBox(height: Spacing.sm),
        Text('Where do you practice?', style: theme.textTheme.headlineMedium),
        const SizedBox(height: Spacing.xs),
        Text(
          'Set up your clinics with rent, consultation fees & targets.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        for (var i = 0; i < clinics.length; i++) ...[
          _ClinicCard(
            index: i,
            controllers: clinics[i],
            nameFocus: i == 0 ? firstNameFocus : null,
            areaFocus: i == 0 ? firstAreaFocus : null,
            canRemove: clinics.length > 1,
            onRemove: () => onRemoveClinic(i),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            isLast: i == clinics.length - 1,
          ),
          const SizedBox(height: Spacing.md),
        ],
        AppButton.tonal(
          label: 'Add Another Clinic',
          icon: Icons.add,
          fullWidth: true,
          onPressed: onAddClinic,
        ),
      ],
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final int index;
  final _ClinicFormControllers controllers;
  final FocusNode? nameFocus;
  final FocusNode? areaFocus;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final bool isLast;

  const _ClinicCard({
    required this.index,
    required this.controllers,
    this.nameFocus,
    this.areaFocus,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    required this.onSubmitted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Clinic ${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove clinic',
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          CustomTextField(
            controller: controllers.nameController,
            label: 'Clinic Name',
            prefixIcon: Icons.local_hospital_outlined,
            onChanged: (_) => onChanged(),
            focusNode: nameFocus,
            autofocus: index == 0,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => areaFocus?.requestFocus(),
          ),
          const SizedBox(height: Spacing.md),
          CustomTextField(
            controller: controllers.addressController,
            label: 'Address / Area (Optional)',
            prefixIcon: Icons.place_outlined,
            onChanged: (_) => onChanged(),
            focusNode: areaFocus,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: Spacing.md),
          CustomTextField(
            controller: controllers.phoneController,
            label: 'Clinic Phone (Optional)',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (_) => onChanged(),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controllers.rentController,
                  label: 'Monthly Rent (₹)',
                  prefixIcon: Icons.home_work_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: controllers.feeController,
                  label: 'Default Fee (₹)',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          DaySelectorField(
            label: 'Practice Days',
            value: controllers.openDays,
            onChanged: (v) {
              controllers.openDays = v;
              onChanged();
            },
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'MONTHLY PRACTICE TARGETS',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controllers.revGoalController,
                  label: 'Revenue Goal (₹)',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: CustomTextField(
                  controller: controllers.patGoalController,
                  label: 'New Patients Goal',
                  prefixIcon: Icons.person_add_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  textInputAction:
                      isLast ? TextInputAction.done : TextInputAction.next,
                  onFieldSubmitted: isLast ? (_) => onSubmitted() : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
