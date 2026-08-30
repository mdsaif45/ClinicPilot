import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/master_disease_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/patient_provider.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialDisease;
  final String? initialClinicId;

  const AddPatientDialog({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialDisease,
    this.initialClinicId,
  });

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serialController = TextEditingController();
  DateTime _entryDate = DateTime.now();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _areaController = TextEditingController();
  late final TextEditingController _diseaseController;

  bool _isOnlineConsultation = false;
  String _onlineMedium = 'WhatsApp Video Call';
  String _gender = 'Male';
  String? _selectedClinicId;
  String? _clinicError;
  String _referralSource = 'Direct Walk-in';

  bool _submitting = false;

  final List<String> _onlineMediums = [
    'WhatsApp Video Call',
    'Phone Call',
    'WhatsApp Chat',
    'Google Meet / Zoom',
  ];

  final List<String> _referralSources = [
    'Direct Walk-in',
    'Social Media (Instagram / Facebook)',
    'Patient Referral',
    'Doctor Referral',
    'Google Search / Website',
    'Camp / Event',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _diseaseController = TextEditingController(text: widget.initialDisease ?? '');

    final initialClinic = widget.initialClinicId ?? ref.read(activeClinicIdProvider);
    if (initialClinic == 'clinic_online') {
      _isOnlineConsultation = true;
      _selectedClinicId = 'clinic_online';
      _referralSource = 'Social Media (Instagram / Facebook)';
    } else {
      _isOnlineConsultation = false;
      _selectedClinicId = initialClinic;
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _areaController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final allClinics = clinicsAsync.value ?? [];
    final physicalClinics = allClinics.where((c) => c.id != 'clinic_online').toList();

    if (_selectedClinicId == null && physicalClinics.isNotEmpty && !_isOnlineConsultation) {
      _selectedClinicId = physicalClinics.first.id;
    }

    final serialText = _serialController.text.trim();
    final liveSerialInUse = _isOnlineConsultation || serialText.isEmpty || _selectedClinicId == null
        ? false
        : ref
                .watch(serialNoInUseProvider(SerialLookupArgs(
                  clinicId: _selectedClinicId!,
                  serialNo: serialText,
                )))
                .value ==
            true;

    if (clinicsAsync.hasValue && physicalClinics.isEmpty && !_isOnlineConsultation) {
      return AppFormDialog(
        title: 'Register New Patient',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
        child: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before registering a patient.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
      );
    }

    return AppFormDialog(
      title: 'Register New Patient',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Register & Create Visit'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consultation Mode Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: Radii.mdAll,
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _isOnlineConsultation = false;
                        final active = widget.initialClinicId ?? ref.read(activeClinicIdProvider);
                        _selectedClinicId = (active != null && active != 'clinic_online')
                            ? active
                            : physicalClinics.firstOrNull?.id;
                        if (_referralSource == 'Social Media (Instagram / Facebook)') {
                          _referralSource = 'Direct Walk-in';
                        }
                      }),
                      borderRadius: Radii.smAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isOnlineConsultation ? scheme.surface : Colors.transparent,
                          borderRadius: Radii.smAll,
                          boxShadow: !_isOnlineConsultation
                              ? [
                                  BoxShadow(
                                    color: scheme.shadow.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_hospital_outlined,
                              size: 16,
                              color: !_isOnlineConsultation ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'In-Clinic Visit',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: !_isOnlineConsultation ? FontWeight.bold : FontWeight.w500,
                                color: !_isOnlineConsultation ? scheme.primary : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _isOnlineConsultation = true;
                        _selectedClinicId = 'clinic_online';
                        _referralSource = 'Social Media (Instagram / Facebook)';
                      }),
                      borderRadius: Radii.smAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isOnlineConsultation ? scheme.surface : Colors.transparent,
                          borderRadius: Radii.smAll,
                          boxShadow: _isOnlineConsultation
                              ? [
                                  BoxShadow(
                                    color: scheme.shadow.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.language,
                              size: 16,
                              color: _isOnlineConsultation ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online / Remote',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: _isOnlineConsultation ? FontWeight.bold : FontWeight.w500,
                                color: _isOnlineConsultation ? scheme.primary : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            // In-Clinic Serial No. input
            if (!_isOnlineConsultation) ...[
              CustomTextField(
                controller: _serialController,
                label: 'Serial No.',
                prefixIcon: Icons.tag,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (liveSerialInUse) {
                    return 'Serial ${v.trim()} is already used at this clinic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),
            ],

            DateField(
              label: 'Patient Entry Date',
              value: _entryDate,
              onChanged: (d) => setState(() => _entryDate = d),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _nameController,
              label: 'Patient Full Name',
              prefixIcon: Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _whatsappController,
              label: 'WhatsApp Number (Optional)',
              prefixIcon: Icons.chat,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address (Optional)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    prefixIcon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.age,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Gender',
                    prefixIcon: Icons.wc,
                    value: _gender,
                    options: const [
                      PickerOption(value: 'Male', label: 'Male'),
                      PickerOption(value: 'Female', label: 'Female'),
                      PickerOption(value: 'Other', label: 'Other'),
                    ],
                    onChanged: (val) => setState(() => _gender = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _areaController,
              label: _isOnlineConsultation ? 'City / State / Location' : 'Locality / Area',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: Spacing.md),

            // Clinic selector or Online teleconsultation badge
            if (_isOnlineConsultation) ...[
              PickerField<String>(
                label: 'Consultation Medium',
                prefixIcon: Icons.video_camera_front_outlined,
                value: _onlineMedium,
                options: _onlineMediums.map((m) => PickerOption(value: m, label: m)).toList(),
                onChanged: (val) => setState(() => _onlineMedium = val),
              ),
              const SizedBox(height: Spacing.md),
            ] else ...[
              PickerField<String>(
                label: 'Clinic',
                prefixIcon: Icons.local_hospital,
                value: _selectedClinicId,
                errorText: _clinicError,
                options: physicalClinics
                    .map((c) => PickerOption(
                          value: c.id,
                          label: c.name,
                          subtitle: c.address,
                        ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedClinicId = val;
                  _clinicError = null;
                }),
              ),
              const SizedBox(height: Spacing.md),
            ],

            DiseaseAutocompleteField(
              controller: _diseaseController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            PickerField<String>(
              label: 'Referral Source (New Patient)',
              prefixIcon: Icons.campaign,
              value: _referralSource,
              options: _referralSources
                  .map((r) => PickerOption(value: r, label: r))
                  .toList(),
              onChanged: (val) => setState(() => _referralSource = val),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    final effectiveClinicId = _isOnlineConsultation ? 'clinic_online' : _selectedClinicId;

    setState(() {
      _clinicError = effectiveClinicId == null ? 'Please select a clinic' : null;
    });

    if (!formOk || effectiveClinicId == null) {
      AppHaptics.error();
      return;
    }

    setState(() => _submitting = true);

    final serialNo = _isOnlineConsultation ? '' : _serialController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final email = _emailController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final area = _areaController.text.trim();
    final disease = Formatters.toTitleCase(_diseaseController.text);
    final notes = _isOnlineConsultation ? 'Consultation Medium: $_onlineMedium' : null;

    try {
      final patient =
          await ref.read(patientNotifierProvider.notifier).registerPatient(
                name: name,
                phone: phone,
                whatsapp: whatsapp.isEmpty ? null : whatsapp,
                email: email.isEmpty ? null : email,
                age: age,
                gender: _gender,
                area: area.isEmpty ? null : area,
                primaryClinicId: effectiveClinicId,
                serialNo: serialNo,
                disease: disease,
                referralSource: _referralSource,
                notes: notes,
                entryDate: _entryDate,
                consultationType: _isOnlineConsultation ? 'online' : 'clinic',
              );
      if (disease.isNotEmpty) {
        ref.read(masterDiseaseServiceProvider).recordDisease(disease);
      }
      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(patient.id);
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not register patient: $e')),
        );
      }
      return;
    }
  }
}
