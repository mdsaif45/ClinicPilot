import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../providers/patient_provider.dart';

/// Searchable patient selector.
///
/// Replaces the plain dropdown that was previously used to pick a patient. A
/// flat list cannot scale past a few dozen patients, and — more importantly —
/// it gives no way to tell two patients with the same name apart. Billing the
/// wrong patient silently corrupts lifetime value and per-clinic revenue, and
/// nothing in the UI would reveal the mistake.
///
/// Every row therefore shows the patient code, phone, age/gender, area and last
/// visit, which is enough to disambiguate in practice.
class PatientPicker extends ConsumerStatefulWidget {
  const PatientPicker({super.key});

  /// Opens the picker and resolves to the chosen patient, or null if dismissed.
  static Future<Patient?> show(BuildContext context) {
    return showModalBottomSheet<Patient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PatientPicker(),
    );
  }

  @override
  ConsumerState<PatientPicker> createState() => _PatientPickerState();
}

class _PatientPickerState extends ConsumerState<PatientPicker> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  /// Debounced so a query does not run on every keystroke.
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus so the doctor can start typing immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(patientSearchProvider(_query));
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text('Select Patient',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search name, phone or code',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onQueryChanged('');
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (_query.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent patients',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.hintColor),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: resultsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Search failed: $e')),
                  data: (results) {
                    if (results.isEmpty) {
                      return _EmptyState(query: _query);
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) =>
                          _PatientTile(result: results[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PatientTile extends StatelessWidget {
  final PatientSearchResult result;

  const _PatientTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final p = result.patient;
    final theme = Theme.of(context);

    final scheme = theme.colorScheme;
    final gender = p.gender.isNotEmpty ? p.gender[0].toUpperCase() : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Text(
          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Same anatomy as the patient directory, so a name recognised on one
      // screen is recognised the same way here.
      title: Row(
        children: [
          Expanded(
            child: Text(
              p.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text('${p.age} $gender', style: theme.textTheme.labelMedium),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.call, size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(p.phone, style: theme.textTheme.labelMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p.patientCode,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context).pop(p),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'No patients registered yet'
                  : 'No patients match "$query"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Register the patient from the Patients tab first.',
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form field that opens [PatientPicker] and displays the chosen patient.
class PatientPickerField extends StatelessWidget {
  final Patient? selected;
  final ValueChanged<Patient> onSelected;
  final String? errorText;

  const PatientPickerField({
    super.key,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final p = selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await PatientPicker.show(context);
            if (picked != null) onSelected(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_search),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              errorText: errorText,
            ),
            child: p == null
                ? Text(
                    'Tap to search patient',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  )
                // Show the code alongside the name so the choice is verifiable
                // before saving.
                : Text(
                    '${p.name}  ·  ${p.patientCode}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
