import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../design/tokens.dart';
import '../services/app_haptics.dart';
import '../services/contact_service.dart';

/// Modal bottom sheet allowing the physician to select between 3 pre-filled
/// templates or edit the custom message before launching WhatsApp.
class WhatsAppTemplatePickerSheet extends StatefulWidget {
  final Patient patient;
  final String clinicName;
  final DateTime? dueDate;

  const WhatsAppTemplatePickerSheet({
    super.key,
    required this.patient,
    required this.clinicName,
    this.dueDate,
  });

  static Future<void> show(
    BuildContext context, {
    required Patient patient,
    required String clinicName,
    DateTime? dueDate,
  }) {
    AppHaptics.light();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (_) => WhatsAppTemplatePickerSheet(
            patient: patient,
            clinicName: clinicName,
            dueDate: dueDate,
          ),
    );
  }

  @override
  State<WhatsAppTemplatePickerSheet> createState() =>
      _WhatsAppTemplatePickerSheetState();
}

class _WhatsAppTemplatePickerSheetState
    extends State<WhatsAppTemplatePickerSheet> {
  int _selectedTemplate = 0;
  late final TextEditingController _messageController;

  late final List<({String title, IconData icon, String message})> _templates;

  @override
  void initState() {
    super.initState();
    _templates = [
      (
        title: 'Follow-up Check-in',
        icon: Icons.event_repeat,
        message: ContactService.followUpMessage(
          patientName: widget.patient.name,
          clinicName: widget.clinicName,
          dueDate: widget.dueDate,
        ),
      ),
      (
        title: 'Health & Dosage Tip',
        icon: Icons.health_and_safety_outlined,
        message: ContactService.healthTipMessage(
          patientName: widget.patient.name,
          clinicName: widget.clinicName,
        ),
      ),
      (
        title: 'Free Camp / Clinic Invite',
        icon: Icons.campaign_outlined,
        message: ContactService.campInviteMessage(
          patientName: widget.patient.name,
          clinicName: widget.clinicName,
        ),
      ),
    ];

    _messageController = TextEditingController(text: _templates[0].message);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSelectTemplate(int index) {
    AppHaptics.selection();
    setState(() {
      _selectedTemplate = index;
      _messageController.text = _templates[index].message;
    });
  }

  Future<void> _send() async {
    AppHaptics.success();
    final phone =
        widget.patient.whatsapp?.isNotEmpty == true
            ? widget.patient.whatsapp!
            : widget.patient.phone;

    if (phone.trim().isEmpty) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No phone number recorded for this patient.'),
          ),
        );
      }
      return;
    }

    final ok = await ContactService.openWhatsApp(
      phone: phone,
      message: _messageController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.xl + insets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat, color: scheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Message ${widget.patient.name}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Select a quick template or edit the text before opening WhatsApp:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),
            for (var i = 0; i < _templates.length; i++) ...[
              RadioListTile<int>(
                value: i,
                groupValue: _selectedTemplate,
                onChanged: (val) => val != null ? _onSelectTemplate(val) : null,
                title: Text(
                  _templates[i].title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                secondary: Icon(_templates[i].icon, color: scheme.primary),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: Radii.smAll),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Open WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
