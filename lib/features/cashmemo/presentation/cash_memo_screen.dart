import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashMemoScreen extends ConsumerWidget {
  const CashMemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Memo"),
      ),
      body: const Center(
        child: Text("Cash Memo Screen"),
      ),
    );
  }
}
