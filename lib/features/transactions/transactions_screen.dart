import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/utils/balance_utils.dart';
import '../../core/utils/currency_format.dart';
import '../../data/providers.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../shared/widgets/app_fade_in.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final wallets = ref.watch(walletsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) {
          final filtered = _filter == 'all' ? transactions : transactions.where((t) => t.type == _filter).toList();
          final now = DateTime.now();
          final monthTx = transactions.where((t) => t.date.year == now.year && t.date.month == now.month);
          final income = monthTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + t.amount);
          final expense = monthTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amount);
          final tt = Theme.of(context).textTheme;
          final cs = Theme.of(context).colorScheme;

          return AppFadeIn(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'Masuk', value: CurrencyFormat.compactIdr(income), color: AppColors.income)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(label: 'Keluar', value: CurrencyFormat.compactIdr(expense), color: AppColors.expense)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(label: 'Net', value: CurrencyFormat.compactIdr(income - expense), color: cs.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Dompet', style: tt.titleMedium),
              ),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: wallets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final w = wallets[i];
                    final bal = walletBalance(w, transactions);
                    return Container(
                      width: 160,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(radius: 15, backgroundColor: Color(w.color), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 15)),
                          const Spacer(),
                          Text(w.name, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(CurrencyFormat.compactIdr(bal), style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    for (final entry in const {'all': 'Semua', 'expense': 'Keluar', 'income': 'Masuk', 'transfer': 'Transfer'}.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: _filter == entry.key,
                          onSelected: (_) => setState(() => _filter = entry.key),
                        ),
                      ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada transaksi.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
                )
              else
                ...filtered.map((tx) {
                  final cat = categories.where((c) => c.id == tx.categoryId).firstOrNull;
                  final isIncome = tx.type == 'income';
                  final isTransfer = tx.type == 'transfer';
                  final sign = isIncome ? '+' : (isTransfer ? '' : '-');
                  final color = isIncome ? AppColors.income : (isTransfer ? AppColors.transfer : AppColors.expense);
                  final title = tx.title.isNotEmpty ? tx.title : (isTransfer ? 'Transfer' : (cat?.name ?? 'Tanpa kategori'));
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(isTransfer ? Icons.swap_horiz : (isIncome ? Icons.south_west : Icons.north_east), color: color, size: 20),
                    ),
                    title: Text(title, style: tt.titleSmall),
                    subtitle: Text('${DateFormat('dd MMM yyyy', 'id_ID').format(tx.date)}${tx.note.isNotEmpty ? ' • ${tx.note}' : ''}'),
                    trailing: Text('$sign${CurrencyFormat.idr(tx.amount)}', style: tt.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                    onTap: () => TransactionFormScreen.show(context, transaction: tx),
                    onLongPress: () => _confirmDelete(context, tx.id),
                  );
                }),
            ],
          ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionFormScreen.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      sheetAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 400), reverseDuration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Hapus transaksi?', style: tt.titleLarge),
                const SizedBox(height: 8),
                Text('Transaksi yang dihapus tidak bisa dikembalikan.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok == true) {
      await TransactionRepository(ref.read(databaseProvider)).deleteTransaction(id);
    }
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
