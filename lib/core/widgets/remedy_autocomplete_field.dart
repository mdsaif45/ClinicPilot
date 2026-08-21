import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Curated list of standard Latin binomial homeopathic remedies.
const List<String> kCuratedRemedies = [
  'Aconitum Napellus',
  'Apis Mellifica',
  'Arnica Montana',
  'Arsenicum Album',
  'Belladonna',
  'Berberis Vulgaris',
  'Bryonia Alba',
  'Calcarea Carbonica',
  'Calcarea Fluorica',
  'Calcarea Phosphorica',
  'Cantharis Vesicatoria',
  'Carbo Vegetabilis',
  'Causticum',
  'Chamomilla',
  'Chelidonium Majus',
  'China Officinalis',
  'Colocynthis',
  'Drosera Rotundifolia',
  'Dulcamara',
  'Euphrasia Officinalis',
  'Gelsemium Sempervirens',
  'Graphites',
  'Hamamelis Virginiana',
  'Hepar Sulphuris Calcareum',
  'Hypericum Perforatum',
  'Ignatia Amara',
  'Ipecacuanha',
  'Kali Bichromicum',
  'Kali Carbonicum',
  'Kalmia Latifolia',
  'Lachesis Mutus',
  'Ledum Palustre',
  'Lycopodium Clavatum',
  'Magnesia Phosphorica',
  'Mercurius Solubilis',
  'Natrum Muriaticum',
  'Natrum Sulphuricum',
  'Nitricum Acidum',
  'Nux Vomica',
  'Phosphorus',
  'Phytolacca Decandra',
  'Plumbum Metallicum',
  'Pulsatilla Nigricans',
  'Rhus Toxicodendron',
  'Ruta Graveolens',
  'Sepia Officinalis',
  'Silicea Terra',
  'Spigelia Anthelmia',
  'Staphysagria',
  'Sulphur',
  'Symphytum Officinale',
  'Thuja Occidentalis',
  'Veratrum Album',
];

/// Smart autocomplete picker for standardized Latin remedy names.
class RemedyAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSelected;

  const RemedyAutocompleteField({
    super.key,
    required this.controller,
    this.label = 'Remedy Name (Latin Binomial) *',
    this.hint = 'e.g. Thuja Occidentalis, Nux Vomica',
    this.validator,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return kCuratedRemedies.take(8);
        }
        return kCuratedRemedies.where((String option) {
          return option.toLowerCase().contains(query);
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
        onSelected?.call(selection);
      },
      optionsViewBuilder: (context, onSelectedOption, options) {
        final theme = Theme.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: Radii.mdAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelectedOption(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(Icons.medication_outlined),
          ),
          validator: validator,
          onFieldSubmitted: (v) => onFieldSubmitted(),
        );
      },
    );
  }
}
