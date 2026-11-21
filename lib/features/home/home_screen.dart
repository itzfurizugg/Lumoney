import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/utils/balance_utils.dart';
import '../../core/utils/currency_format.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_fade_in.dart';
import '../settings/settings_screen.dart';
import '../transactions/transaction_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String _greeting;
  late String _timePeriod;
  Timer? _timer;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _timePeriod = _currentPeriod();
    _greeting = _pickGreeting(_timePeriod);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refreshGreeting());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _currentPeriod() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return 'Pagi';
    if (h >= 11 && h < 15) return 'Siang';
    if (h >= 15 && h < 18) return 'Sore';
    return 'Malam';
  }

  String _pickGreeting(String period) {
    const user = 'user';
    final options = [
      'Selamat $period, $user!',
      '$period, $user!',
      'Halo, $user!',
      'Dashboard',
    ];
    return options[_rand.nextInt(options.length)];
  }

  void _refreshGreeting() {
    final period = _currentPeriod();
    if (period != _timePeriod) {
      setState(() {
        _timePeriod = period;
        _greeting = _pickGreeting(period);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);
    final txAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallets) => txAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (transactions) {
            final categories = categoriesAsync.valueOrNull ?? [];
            final total = totalBalance(wallets, transactions);
            final now = DateTime.now();
            final monthTx = transactions.where((t) => t.date.year == now.year && t.date.month == now.month && t.type != 'transfer');
            final income = monthTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + t.amount);
            final expense = monthTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amount);
            final recent = transactions.take(6).toList();

            return AppFadeIn(
              child: ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text('Saldo', style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                  child: Text(
                    CurrencyFormat.idr(total),
                    style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          label: 'Pemasukan',
                          amount: income,
                          color: AppColors.income,
                          icon: Icons.arrow_downward_rounded,
                          onTap: () => TransactionFormScreen.show(context, initialType: 'income'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          label: 'Pengeluaran',
                          amount: expense,
                          color: AppColors.expense,
                          icon: Icons.arrow_upward_rounded,
                          onTap: () => TransactionFormScreen.show(context, initialType: 'expense'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text('Dompet', style: tt.titleMedium),
                ),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: wallets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final w = wallets[i];
                      final bal = walletBalance(w, transactions);
                      return Container(
                        width: 170,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: Color(w.color), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 16)),
                            const Spacer(),
                            Text(w.name, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(CurrencyFormat.idr(bal), style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text('Transaksi Terbaru', style: tt.titleMedium),
                ),
                if (recent.isEmpty)
                  Padding(padding: const EdgeInsets.all(20), child: Text('Belum ada transaksi.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                else
                  ...recent.map((tx) {
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
                      subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(tx.date)),
                      trailing: Text('$sign${CurrencyFormat.idr(tx.amount)}', style: tt.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                      onTap: () => TransactionFormScreen.show(context, transaction: tx),
                    );
                  }),
              ],
            ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionFormScreen.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.label, required this.amount, required this.color, required this.icon, required this.onTap});
  final String label;
  final int amount;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(label, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(CurrencyFormat.compactIdr(amount), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
