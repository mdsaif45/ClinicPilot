import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../utils/date_input_formatter.dart';
import '../utils/formatters.dart';

/// Labelled date selector that supports both calendar picker popup and manual
/// typing in (DD/MM/YYYY) format with automatic slash separator insertion.
class DateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;
  final VoidCallback? onCleared;

  const DateField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.controller,
    this.prefixIcon = Icons.event_outlined,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.onCleared,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final TextEditingController _internalController;
  bool _isSelfManaged = false;

  TextEditingController get _activeController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _isSelfManaged = true;
      _internalController = TextEditingController(
        text: widget.value != null ? Formatters.formatDdMmYyyy(widget.value!) : '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSelfManaged && widget.value != oldWidget.value) {
      final formatted =
          widget.value != null ? Formatters.formatDdMmYyyy(widget.value!) : '';
      if (_internalController.text != formatted) {
        _internalController.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    if (_isSelfManaged) {
      _internalController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = widget.value ?? now;
    if (_activeController.text.isNotEmpty) {
      final parsed = Formatters.parseDateString(_activeController.text);
      if (parsed != null) initial = parsed;
    }

    final first = widget.firstDate ?? DateTime(1900);
    final last = widget.lastDate ?? DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first)
          ? first
          : (initial.isAfter(last) ? last : initial),
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      final formatted = Formatters.formatDdMmYyyy(picked);
      _activeController.text = formatted;
      widget.onChanged?.call(picked);
    }
  }

  void _onTextChanged(String text) {
    if (text.length == 10) {
      final parsed = Formatters.parseDateString(text);
      if (parsed != null) {
        widget.onChanged?.call(parsed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: _activeController,
          keyboardType: TextInputType.number,
          inputFormatters: const [DateInputFormatter()],
          onChanged: _onTextChanged,
          validator: widget.validator,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'DD/MM/YYYY',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              tooltip: 'Choose date from calendar',
              onPressed: () => _pickDate(context),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
