import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/app_bar_back_button.dart';
import '../wallets/wallets_screen.dart';
import 'appearance_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        leadingWidth: 60,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text('Umum', style: tt.titleMedium),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: Icon(Icons.palette_outlined, color: cs.onPrimaryContainer)),
                  title: Text('Tampilan', style: tt.titleSmall),
                  subtitle: const Text('Mode gelap & warna aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen())),
                ),
                Divider(height: 1, indent: 72, color: cs.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: CircleAvatar(backgroundColor: cs.secondaryContainer, child: Icon(Icons.account_balance_wallet_outlined, color: cs.onSecondaryContainer)),
                  title: Text('Dompet', style: tt.titleSmall),
                  subtitle: const Text('Kelola dompet cash, bank, dan lainnya'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletsScreen())),
                ),
                Divider(height: 1, indent: 72, color: cs.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: CircleAvatar(backgroundColor: cs.tertiaryContainer, child: Icon(Icons.category_outlined, color: cs.onTertiaryContainer)),
                  title: Text('Kategori', style: tt.titleSmall),
                  subtitle: const Text('Segera hadir'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: cs.surfaceContainerHighest, child: Icon(Icons.info_outline, color: cs.onSurfaceVariant)),
              title: Text('Tentang', style: tt.titleSmall),
              subtitle: const Text('Lumoney v0.1.0 · Local-first money manager'),
            ),
          ),
        ],
      ),
    );
  }
}
