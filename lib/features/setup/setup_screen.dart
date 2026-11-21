import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app.dart';
import '../../data/providers.dart';
import '../../data/repositories/wallet_repository.dart';
import '../wallets/wallet_form_screen.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  static const setupDoneKey = 'setup_done';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: walletsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (wallets) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(28)),
                  child: Icon(Icons.account_balance_wallet, size: 44, color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 24),
                Text('Selamat datang\ndi Lumoney', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                  'Siapkan dompet pertamamu. Tambahkan cash, bank, atau e-wallet untuk mulai mencatat keuangan.',
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.payments, size: 18),
                      label: const Text('Cash'),
                      onPressed: () => _quickAdd(context, ref, name: 'Cash', icon: 'payments', color: 0xFF2E7D32),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.account_balance, size: 18),
                      label: const Text('Bank'),
                      onPressed: () => _quickAdd(context, ref, name: 'Bank', icon: 'account_balance', color: 0xFF1565C0),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Kustom'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletFormScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Dompet kamu', style: tt.titleMedium),
                const SizedBox(height: 8),
                if (wallets.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Belum ada dompet. Tambahkan minimal satu dompet untuk mulai.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                  )
                else
                  ...wallets.map((w) => Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Color(w.color), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
                          title: Text(w.name, style: tt.titleSmall),
                          subtitle: Text('Saldo awal: Rp ${w.initialBalance}'),
                        ),
                      )),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: wallets.isEmpty ? null : () => _finish(context),
                  child: const Text('Mulai'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _quickAdd(BuildContext context, WidgetRef ref, {required String name, required String icon, required int color}) async {
    final existing = ref.read(walletsProvider).valueOrNull ?? [];
    if (existing.any((w) => w.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dompet $name sudah ada')));
      return;
    }
    await WalletRepository(ref.read(databaseProvider)).create(name: name, icon: icon, color: color, initialBalance: 0);
  }

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(setupDoneKey, true);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (_) => false,
    );
  }
}
