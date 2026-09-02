import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/custom_badge.dart';
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

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ReferralContact contact,
  ) {
    AppHaptics.error();
    showDialog(
      context: context,
      builder:
          (ctx) => AppConfirmDialog(
            title: 'Delete Partner',
            message:
                'Are you sure you want to remove "${contact.name}" from the referral network?',
            confirmLabel: 'Delete',
            isDestructive: true,
            onConfirm: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(referralCrmNotifierProvider.notifier)
                  .deleteContact(contact.id);
              AppHaptics.medium();
            },
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

    final filteredContacts =
        allContacts.where((c) {
          final matchesCat =
              _selectedCategory == null || c.category == _selectedCategory;
          final matchesQuery =
              query.isEmpty ||
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
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                Spacing.sm,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search pharmacy, lab, clinic, locality...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                              : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: 12,
                      ),
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
                              setState(
                                () => _selectedCategory = selected ? cat : null,
                              );
                            },
                          ),
                          const SizedBox(width: Spacing.xs),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
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
                  message:
                      query.isNotEmpty
                          ? 'No partners matching "$query". Try clearing search filters.'
                          : 'Build professional outreach with nearby pharmacies, labs & practitioners to grow your practice footfalls.',
                  actionLabel: 'Add First Partner',
                  onAction: () => _openAddPartner(context),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.xs,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final contact = filteredContacts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: _PartnerCard(
                      contact: contact,
                      onEdit: () => _openEditPartner(context, contact),
                      onDelete: () => _confirmDelete(context, ref, contact),
                      onLogVisit: () {
                        AppHaptics.selection();
                        ref
                            .read(referralCrmNotifierProvider.notifier)
                            .logOutreachVisit(contact.id);
                      },
                      onAddReferral: () {
                        AppHaptics.selection();
                        ref
                            .read(referralCrmNotifierProvider.notifier)
                            .incrementReferralCount(contact.id);
                      },
                    ),
                  );
                }, childCount: filteredContacts.length),
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
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtext,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatefulWidget {
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
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contact = widget.contact;

    final hasContactPerson = (contact.contactPerson ?? '').trim().isNotEmpty;
    final hasPhone = (contact.phone ?? '').trim().isNotEmpty;
    final hasAddress = (contact.address ?? '').trim().isNotEmpty;
    final hasNotes = (contact.notes ?? '').trim().isNotEmpty;
    final hasLastVisit = contact.lastVisitedDate != null;

    final hasSecondaryDetails =
        hasContactPerson || hasPhone || hasAddress || hasNotes || hasLastVisit;

    // Concise location / context subtitle
    String? subtitleText;
    if (hasAddress) {
      subtitleText = contact.address;
    } else if (hasContactPerson) {
      subtitleText = 'Contact: ${contact.contactPerson}';
    }

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LAYER 1: PARTNER IDENTITY & CATEGORY ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitleText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              CustomBadge(label: contact.category, color: scheme.primary),
              const SizedBox(width: Spacing.xs),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: 'Partner options',
                onSelected: (val) {
                  switch (val) {
                    case 'edit':
                      widget.onEdit();
                      break;
                    case 'call':
                      if (hasPhone) {
                        AppHaptics.selection();
                        ContactService.call(contact.phone!);
                      }
                      break;
                    case 'whatsapp':
                      if (hasPhone) {
                        AppHaptics.selection();
                        ContactService.openWhatsApp(
                          phone: contact.phone!,
                          message:
                              'Hello ${contact.contactPerson ?? contact.name}, Dr. Saifuddin here from City Care Homeopathy.',
                        );
                      }
                      break;
                    case 'delete':
                      widget.onDelete();
                      break;
                  }
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: Spacing.sm),
                            Text('Edit Partner'),
                          ],
                        ),
                      ),
                      if (hasPhone) ...[
                        const PopupMenuItem(
                          value: 'call',
                          child: Row(
                            children: [
                              Icon(Icons.call_outlined, size: 18),
                              SizedBox(width: Spacing.sm),
                              Text('Call Partner'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'whatsapp',
                          child: Row(
                            children: [
                              Icon(Icons.chat_outlined, size: 18),
                              SizedBox(width: Spacing.sm),
                              Text('WhatsApp Message'),
                            ],
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: scheme.error,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Text(
                              'Delete',
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // ── LAYER 2: KEY OPERATIONAL METRICS ──────────────────────
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomBadge(
                icon: Icons.people_outline,
                label:
                    '${contact.referralCount} ${contact.referralCount == 1 ? 'Referral' : 'Referrals'}',
                color: scheme.tertiary,
              ),
              CustomBadge(
                icon: Icons.directions_walk_outlined,
                label:
                    '${contact.visitCount} ${contact.visitCount == 1 ? 'Doctor Visit' : 'Doctor Visits'}',
                color: scheme.secondary,
              ),
              if (hasLastVisit)
                CustomBadge(
                  label:
                      'Last: ${Formatters.formatDate(contact.lastVisitedDate!)}',
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),

          // ── PROGRESSIVE DISCLOSURE AFFORDANCE ─────────────────────
          if (hasSecondaryDetails) ...[
            const SizedBox(height: Spacing.xs),
            InkWell(
              onTap: () {
                AppHaptics.selection();
                setState(() => _expanded = !_expanded);
              },
              borderRadius: Radii.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Hide details' : 'View contact & notes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color:
                          _expanded ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── EXPANDED SECONDARY DETAILS ────────────────────────────
          if (_expanded && hasSecondaryDetails) ...[
            const Divider(height: 12),
            if (hasContactPerson && hasAddress)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Contact: ${contact.contactPerson!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasPhone)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      contact.phone!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      tooltip: 'WhatsApp message',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        AppHaptics.selection();
                        ContactService.openWhatsApp(
                          phone: contact.phone!,
                          message:
                              'Hello ${contact.contactPerson ?? contact.name}, Dr. Saifuddin here from City Care Homeopathy.',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_outlined, size: 18),
                      tooltip: 'Call partner',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        AppHaptics.selection();
                        ContactService.call(contact.phone!);
                      },
                    ),
                  ],
                ),
              ),
            if (hasNotes)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.xs + 2),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  'Notes: ${contact.notes!}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],

          const SizedBox(height: Spacing.sm),

          // ── LAYER 3: CORE PRIMARY ACTIONS ─────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: 'Log Visit',
                  icon: Icons.directions_walk_outlined,
                  fullWidth: true,
                  onPressed: widget.onLogVisit,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: AppButton.tonal(
                  label: '+1 Referral',
                  icon: Icons.person_add_outlined,
                  fullWidth: true,
                  onPressed: widget.onAddReferral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
