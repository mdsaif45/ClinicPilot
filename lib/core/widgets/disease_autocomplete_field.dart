import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../utils/formatters.dart';

/// Curated list of common homeopathic conditions & specialties.
const List<String> kCuratedDiseases = [
  'Acid Peptic Disease / GERD',
  'Allergic Rhinitis / Sneezing',
  'Anxiety / Depression / Insomnia',
  'Asthma / Bronchial Allergy',
  'Atopic Dermatitis / Eczema',
  'Cervical Spondylosis / Neck Pain',
  'Childhood Immunity / Recurrent Cold',
  'Chronic Kidney Disease / Creatinine',
  'Diabetes Mellitus',
  'Fatty Liver / Digestive Disorder',
  'Fever / Viral Infection',
  'Fungal Infection / Ringworm',
  'General Consultation',
  'Hair Fall / Alopecia Areata',
  'Hypertension',
  'Irritable Bowel Syndrome (IBS)',
  'Joint Pain / Osteoarthritis',
  'Kidney Stone / Renal Calculi',
  'Lumbar Spondylosis / Sciatica',
  'Menstrual Disorder / Dysmenorrhea',
  'Migraine / Chronic Headache',
  'PCOS / PCOD',
  'Piles / Anal Fissure / Fistula',
  'Psoriasis',
  'Rheumatoid Arthritis',
  'Sinusitis / Nasal Polyps',
  'Skin Allergy / Urticaria',
  'Thyroid Disorder / Hypothyroid',
  'Tonsillitis / Adenoids',
  'Vitiligo / Leucoderma',
  'Warts / Corns',
  'Other',
];

/// Smart autocomplete picker for standardized condition names.
/// Matches [CustomTextField] and [PickerField] geometry.
class DiseaseAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSelected;

  const DiseaseAutocompleteField({
    super.key,
    required this.controller,
    this.label = 'Primary Disease / Chief Complaint',
    this.hint = 'e.g. Skin Allergy, Asthma, Joint Pain',
    this.validator,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return kCuratedDiseases.take(8);
            }
            return kCuratedDiseases.where((String option) {
              return option.toLowerCase().contains(query);
            });
          },
          onSelected: (String selection) {
            final formatted =
                selection == 'Other' ? '' : Formatters.toTitleCase(selection);
            controller.text = formatted;
            onSelected?.call(formatted);
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
              validator: validator,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
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
                onSelected?.call(Formatters.toTitleCase(value));
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
                  constraints:
                      const BoxConstraints(maxHeight: 220, maxWidth: 320),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: theme.textTheme.bodyMedium,
                        ),
                        onTap: () => onSelected(option),
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
