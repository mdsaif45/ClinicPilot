import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import 'add_edit_referral_contact_dialog.dart';
import '../providers/referral_crm_provider.dart';

class ReferralCrmScreen extends ConsumerStatefulWidget {
  const ReferralCrmScreen({super.key});

  @override
  ConsumerState<ReferralCrmScreen> createState() => _ReferralCrmScreenState();
}

class _ReferralCrmScreenState extends ConsumerState<ReferralCrmScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddPartner(BuildContext context) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => const AddEditReferralContactDialog(),
    );
  }

  void _openEditPartner(BuildContext context, ReferralContact contact) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditReferralContactDialog(existingContact: contact),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ReferralContact contact) {
    AppHaptics.error();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Partner'),
        content: Text('Are you sure you want to remove "${contact.name}" from the referral network?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(referralCrmNotifierProvider.notifier).deleteContact(contact.id);
              AppHaptics.medium();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(referralContactsProvider);
    final stats = ref.watch(referralCrmStatsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final allContacts = contactsAsync.value ?? [];
    final query = _searchController.text.trim().toLowerCase();

    final filteredContacts = allContacts.where((c) {
      final matchesCat = _selectedCategory == null || c.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          (c.contactPerson ?? '').toLowerCase().contains(query) ||
          (c.address ?? '').toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Network CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Add Referral Partner',
            onPressed: () => _openAddPartner(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // KPI Metric Summary Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Network',
                      value: '${stats.totalPartners}',
                      subtext: '${stats.activePartners} Active',
                      icon: Icons.store_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Referrals Sent',
                      value: '${stats.totalReferrals}',
                      subtext: 'Patients',
                      icon: Icons.people_outline,
                      color: scheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Doctor Visits',
                      value: '${stats.totalVisits}',
                      subtext: 'Outreach Logs',
                      icon: Icons.directions_walk_outlined,
                      color: scheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search & Category Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search pharmacy, lab, clinic, locality...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            AppHaptics.selection();
                            setState(() => _selectedCategory = null);
                          },
                        ),
                        const SizedBox(width: Spacing.xs),
                        for (final cat in const [
                          'Pharmacy',
                          'Diagnostic Lab',
                          'Physiotherapy',
                          'Dentist',
                          'Gym / Fitness',
                          'Specialist Doctor',
                          'Other',
                        ]) ...[
                          FilterChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (selected) {
                              AppHaptics.selection();
                              setState(() => _selectedCategory = selected ? cat : null);
                            },
                          ),
                          const SizedBox(width: Spacing.xs),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            ),
          ),

          // Partners List
          if (filteredContacts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(
                  icon: Icons.share_location_outlined,
                  title: 'No referral partners found',
                  message: 'Build your local B2B medical network with pharmacies, diagnostic labs, and gyms.',
                  actionLabel: 'Add Partner',
                  onAction: () => _openAddPartner(context),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contact = filteredContacts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: _PartnerCard(
                        contact: contact,
                        onEdit: () => _openEditPartner(context, contact),
                        onDelete: () => _confirmDelete(context, ref, contact),
                        onLogVisit: () {
                          AppHaptics.medium();
                          ref.read(referralCrmNotifierProvider.notifier).logOutreachVisit(contact.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged outreach visit to ${contact.name}!')),
                          );
                        },
                        onAddReferral: () {
                          AppHaptics.success();
                          ref.read(referralCrmNotifierProvider.notifier).incrementReferralCount(contact.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('+1 referral recorded from ${contact.name}!')),
                          );
                        },
                      ),
                    );
                  },
                  childCount: filteredContacts.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPartner(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Partner'),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtext,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final ReferralContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogVisit;
  final VoidCallback onAddReferral;

  const _PartnerCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onLogVisit,
    required this.onAddReferral,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = contact;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Category badge + More actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((c.contactPerson ?? '').isNotEmpty)
                      Text(
                        'Contact: ${c.contactPerson!}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  c.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: scheme.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Address & Phone
          if ((c.address ?? '').isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    c.address!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
          ],
          if ((c.phone ?? '').isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  c.phone!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'WhatsApp Partner',
                  onPressed: () {
                    AppHaptics.selection();
                    ContactService.openWhatsApp(
                      phone: c.phone!,
                      message: 'Hello ${c.contactPerson ?? c.name}, greetings from the clinic!',
                    );
                  },
                ),
                const SizedBox(width: Spacing.xs),
                IconButton.filledTonal(
                  icon: const Icon(Icons.call_outlined, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Call Partner',
                  onPressed: () {
                    AppHaptics.selection();
                    ContactService.call(c.phone!);
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.sm),

          // CRM Stats & Outreach details
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '${c.referralCount} Patients Referred',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '${c.visitCount} Doctor Visits Logged',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (c.lastVisitedDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: Radii.smAll,
                  ),
                  child: Text(
                    'Last Visited: ${Formatters.formatDate(c.lastVisitedDate!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),

          if ((c.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'Notes: ${c.notes!}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),

          // Action buttons: Log Visit & Add Referral
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLogVisit,
                  icon: const Icon(Icons.directions_walk, size: 16),
                  label: const Text('Log Visit'),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onAddReferral,
                  icon: const Icon(Icons.person_add_alt, size: 16),
                  label: const Text('+1 Referral'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}