import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/cash_memo_provider.dart';
import 'new_cash_memo_dialog.dart';
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
            icon: const Icon(Icons.add_task),
            tooltip: "New Cash Memo",
            onPressed: () => _openNewCashMemo(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewCashMemo(context),
        backgroundColor: const Color(0xFF0F5132),
        icon: const Icon(Icons.receipt, color: Colors.white),
        label: const Text("New Cash Memo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            cashMemosAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (memos) {
                final totalRev = memos.fold<double>(0, (sum, item) => sum + item.memo.total);
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Revenue Generated",
                        value: Formatters.formatCurrency(totalRev),
                        subtitle: "${memos.length} Receipts Issued",
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFF0F5132),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cashMemosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error loading cash memos: $err")),
                data: (memos) {
                  if (memos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No Cash Memos recorded yet",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openNewCashMemo(context),
                            icon: const Icon(Icons.receipt),
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

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F5132).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt, color: Color(0xFF0F5132)),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                patient.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                Formatters.formatCurrency(memo.total),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F5132)),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${memo.memoNumber} • ${Formatters.formatDate(memo.createdAt)}",
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(width: 8),
                                    CustomBadge(label: memo.paymentMethod, color: const Color(0xFF198754)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Consultation: ₹${memo.consultationFee.toInt()} | Medicine: ₹${memo.medicineFee.toInt()}${memo.discount > 0 ? " | Disc: ₹${memo.discount.toInt()}" : ""}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                            tooltip: "View / Print Receipt PDF",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReceiptPreviewDialog(
                                    cashMemo: memo,
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
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
}
