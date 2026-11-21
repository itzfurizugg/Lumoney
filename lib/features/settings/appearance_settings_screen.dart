import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/theme_settings_provider.dart';
import '../../shared/widgets/app_bar_back_button.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final themeSettings = ref.watch(themeSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        leadingWidth: 60,
        title: const Text('Tampilan'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text('Mode tema', style: tt.titleMedium),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Otomatis'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Terang'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Gelap'), icon: Icon(Icons.dark_mode)),
                ],
                selected: {themeSettings.themeMode},
                onSelectionChanged: (s) => ref.read(themeSettingsProvider.notifier).setThemeMode(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Text('Warna', style: tt.titleMedium),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final seed in AppColorSeed.values)
                    _ColorChoice(
                      seed: seed,
                      selected: themeSettings.colorSeed == seed,
                      onTap: () => ref.read(themeSettingsProvider.notifier).setColorSeed(seed),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({required this.seed, required this.selected, required this.onTap});
  final AppColorSeed seed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5), width: selected ? 2 : 1),
          color: selected ? cs.primaryContainer.withValues(alpha: 0.25) : null,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: seed.color,
              child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(height: 6),
            Text(seed.label, style: tt.labelMedium, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
