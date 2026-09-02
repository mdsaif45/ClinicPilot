import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/tokens.dart';
import '../services/master_disease_service.dart';
import '../utils/formatters.dart';

/// Legacy alias for curated default homeopathic diseases list.
const List<String> kCuratedDiseases = kDefaultHomeopathicDiseases;

/// Smart autocomplete picker for standardized condition names.
/// Matches [CustomTextField] and [PickerField] geometry.
class DiseaseAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSelected;

  const DiseaseAutocompleteField({
    super.key,
    required this.controller,
    this.label = 'Primary Disease / Chief Complaint',
    this.hint = '',
    this.validator,
    this.onSelected,
  });

  @override
  ConsumerState<DiseaseAutocompleteField> createState() =>
      _DiseaseAutocompleteFieldState();
}

class _DiseaseAutocompleteFieldState
    extends ConsumerState<DiseaseAutocompleteField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final diseaseOptions =
        ref.watch(masterDiseasesListProvider).value ??
        kDefaultHomeopathicDiseases;

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
        RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return diseaseOptions.take(8);
            }
            return diseaseOptions.where((String option) {
              return option.toLowerCase().contains(query);
            });
          },
          onSelected: (String selection) {
            final formatted =
                selection == 'Other'
                    ? ''
                    : Formatters.toTitleCase(selection.trim());
            widget.controller.text = formatted;
            widget.onSelected?.call(formatted);
            _focusNode.unfocus();
            if (formatted.isNotEmpty) {
              ref.read(masterDiseaseServiceProvider).recordDisease(formatted);
            }
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              validator: widget.validator,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint.isNotEmpty ? widget.hint : null,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.medical_services_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: 14,
                ),
              ),
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
                final formatted = Formatters.toTitleCase(value.trim());
                widget.onSelected?.call(formatted);
                if (formatted.isNotEmpty) {
                  ref
                      .read(masterDiseaseServiceProvider)
                      .recordDisease(formatted);
                }
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: Radii.mdAll,
                color: scheme.surfaceContainerHigh,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 320,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option, style: theme.textTheme.bodyMedium),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
