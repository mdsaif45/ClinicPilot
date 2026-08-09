import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/cash_memo_provider.dart';
import 'new_cash_memo_dialog.dart';
import 'edit_cash_memo_dialog.dart';
import 'receipt_preview_dialog.dart';

class CashMemoScreen extends ConsumerWidget {
  const CashMemoScreen({super.key});

  void _openNewCashMemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const NewCashMemoDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashMemosAsync = ref.watch(cashMemosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Memos & Billing"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Cash Memo",
            onPressed: () => _openNewCashMemo(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewCashMemo(context),
        icon: const Icon(Icons.receipt_long),
        label: const Text("New Cash Memo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Revenue Header Card
            cashMemosAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (memos) {
                final totalRev =
                    memos.fold<double>(0, (sum, item) => sum + item.memo.total);
                final totalPending = memos.fold<double>(
                    0, (sum, item) => sum + item.pendingAmount);

                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Revenue Recorded",
                        value: Formatters.formatCurrency(totalRev),
                        subtitle: "${memos.length} Billing Transactions",
                        icon: Icons.payments_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: "Total Pending Left",
                        value: Formatters.formatCurrency(totalPending),
                        subtitle: "Uncollected Balances",
                        icon: Icons.pending_actions,
                        color: totalPending > 0 ? Colors.red : Colors.teal,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Cash Memos List
            Expanded(
              child: cashMemosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text("Error loading cash memos: $err")),
                data: (memos) {
                  if (memos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No cash memos generated yet",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openNewCashMemo(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Create First Cash Memo"),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: memos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = memos[index];
                      final memo = item.memo;
                      final patient = item.patient;
                      final clinic = item.clinic;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.receipt, color: Colors.teal),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${memo.memoNumber} • ${patient.name}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              CustomBadge(
                                label: memo.paymentMethod,
                                color: Colors.teal,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clinic: ${clinic.name}'),
                                Text(
                                  'Total: ${Formatters.formatCurrency(memo.total)} | Paid: ${Formatters.formatCurrency(memo.paidAmount)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (item.pendingAmount > 0)
                                  Text(
                                    'Pending Left: ${Formatters.formatCurrency(item.pendingAmount)}',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  Formatters.formatDate(memo.createdAt),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.teal),
                                  tooltip: "Edit Cash Memo",
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => EditCashMemoDialog(memo: memo),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined),
                                  tooltip: "Preview Receipt PDF",
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ReceiptPreviewDialog(
                                        cashMemo: memo,
                                        patient: patient,
                                        clinicName: clinic.name,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: "Archive Cash Memo",
                                  onPressed: () =>
                                      _confirmDelete(context, ref, memo.id),
                                ),
                              ],
                            ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Cash Memo'),
        content: const Text('Are you sure you want to archive this cash memo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(cashMemoNotifierProvider.notifier)
                  .archiveCashMemo(id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
