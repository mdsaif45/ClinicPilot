import 'package:flutter/material.dart';
import '../../../core/widgets/picker_field.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/validators.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/patient_provider.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  const AddPatientDialog({super.key});

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serialController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();
  final _areaController = TextEditingController();
  final _diseaseController = TextEditingController();

  String _gender = 'Male';
  String? _selectedClinicId;
  // PickerField is not a FormField, so its error is tracked here - without
  // it, leaving Clinic unset gave no feedback: submit silently did nothing,
  // which read as the button not working rather than as a missing field.
  String? _clinicError;
  String _referralSource = 'Walk-in';

  // Registering awaits a database write. Without this, every tap before that
  // finishes re-ran _submit and created another duplicate patient - the
  // button gave no feedback that the first tap had already been taken.
  bool _submitting = false;

  final List<String> _referralSources = [
    'Walk-in',
    'Google Search',
    'Google Maps',
    'Instagram',
    'Friend/Family',
    'Camp',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClinicId = ref.read(activeClinicIdProvider);
  }

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _areaController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];

    // Watched here, in build, rather than inside CustomTextField's
    // validator: a FormField validator only re-runs when validate() is
    // explicitly called, so it cannot react on its own to a Riverpod
    // provider resolving a moment after the doctor stops typing. Watching
    // in build means the error appears live, the same way it would for any
    // other reactive state in this widget.
    final serialText = _serialController.text.trim();
    final liveSerialInUse = serialText.isEmpty || _selectedClinicId == null
        ? false
        : ref
                .watch(serialNoInUseProvider(SerialLookupArgs(
                  clinicId: _selectedClinicId!,
                  serialNo: serialText,
                )))
                .value ==
            true;

    // A patient has to belong to a clinic - filling in the rest of the form
    // only to hit a foreign-key error at the end is worse than saying so
    // up front, before anything is typed.
    if (clinicsAsync.hasValue && clinics.isEmpty) {
      return AlertDialog(
        title: const Text('Register New Patient'),
        content: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before registering a patient.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Register New Patient'),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Without this the column centres its children. Text fields fill
            // the width so they look correct either way, but anything
            // narrower - chips, checkboxes - drifts to the middle.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _serialController,
                label: 'Serial No.',
                hint: 'As in the register',
                prefixIcon: Icons.tag,
                // Rebuilds on every keystroke so the live duplicate check
                // above re-evaluates without waiting for a form validate().
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (liveSerialInUse) {
                    return 'Serial ${v.trim()} is already used at this clinic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                label: 'Patient Full Name',
                prefixIcon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _whatsappController,
                label: 'WhatsApp Number (Optional)',
                prefixIcon: Icons.chat,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Age',
                      // Not a date picker — age is typed, so avoid a calendar icon.
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.age,
                    ),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              CustomTextField(
                controller: _areaController,
                label: 'Locality / Area',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              PickerField<String>(
                label: 'Clinic',
                prefixIcon: Icons.local_hospital,
                value: _selectedClinicId,
                errorText: _clinicError,
                options: clinics
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
              const SizedBox(height: 12),
              CustomTextField(
                controller: _diseaseController,
                label: 'Disease / Chief Complaint',
                prefixIcon: Icons.medical_services,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
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
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Register & Create Visit'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    setState(() {
      _clinicError = _selectedClinicId == null ? 'Select a clinic' : null;
    });

    if (!formOk || _selectedClinicId == null) return;

    setState(() => _submitting = true);

    final serialNo = _serialController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final area = _areaController.text.trim();
    final disease = _diseaseController.text.trim();

    try {
      await ref.read(patientNotifierProvider.notifier).registerPatient(
            name: name,
            phone: phone,
            whatsapp: whatsapp.isEmpty ? null : whatsapp,
            age: age,
            gender: _gender,
            area: area.isEmpty ? null : area,
            primaryClinicId: _selectedClinicId!,
            serialNo: serialNo,
            disease: disease,
            referralSource: _referralSource,
          );
    } catch (e) {
      // Re-enable the button rather than leave it stuck disabled with no way
      // to retry - a failed write must not trap the doctor in the dialog.
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not register patient: $e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
