import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/balance_utils.dart';
import '../../core/utils/currency_format.dart';
import '../../data/providers.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../shared/widgets/app_bar_back_button.dart';
import '../../shared/widgets/app_fade_in.dart';
import 'wallet_form_screen.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final txs = ref.watch(transactionsProvider).valueOrNull ?? [];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        leadingWidth: 60,
        title: const Text('Dompet'),
      ),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(child: Text('Belum ada dompet. Tap + untuk menambah.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
          }
          return AppFadeIn(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: wallets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final w = wallets[i];
              final bal = walletBalance(w, txs);
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(radius: 22, backgroundColor: Color(w.color), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
                  title: Text(w.name, style: tt.titleSmall),
                  subtitle: Text(CurrencyFormat.idr(bal), style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => _handleAction(context, ref, v, w),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'archive', child: Text('Arsipkan')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WalletFormScreen(wallet: w))),
                ),
              );
            },
          ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action, dynamic wallet) async {
    final repo = WalletRepository(ref.read(databaseProvider));
    if (action == 'edit') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => WalletFormScreen(wallet: wallet)));
      return;
    }
    if (action == 'archive') {
      await repo.updateWallet(wallet, isArchived: true);
      return;
    }
    if (action == 'delete') {
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
                  Text('Hapus dompet?', style: tt.titleLarge),
                  const SizedBox(height: 8),
                  Text('Dompet yang dihapus tidak bisa dikembalikan. Transaksi terkait bisa terpengaruh.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
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
      if (ok == true) await repo.deleteWallet(wallet.id as String);
    }
  }
}
