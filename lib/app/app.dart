import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/app_database.dart';
import '../data/providers.dart';
import '../data/theme_settings_provider.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/savings/savings_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'theme.dart';

class LumoneyApp extends ConsumerWidget {
  const LumoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final seed = settings.colorSeed.color;
    return MaterialApp(
      title: 'Lumoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seed: seed),
      darkTheme: AppTheme.dark(seed: seed),
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOutCubic,
      home: const SetupGate(),
    );
  }
}

class SetupGate extends ConsumerStatefulWidget {
  const SetupGate({super.key});

  @override
  ConsumerState<SetupGate> createState() => _SetupGateState();
}

class _SetupGateState extends ConsumerState<SetupGate> {
  bool? _setupDone;
  ProviderSubscription<AsyncValue<List<Wallet>>>? _walletSub;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void dispose() {
    _walletSub?.close();
    super.dispose();
  }

  Future<void> _resolve() async {
    final prefs = await SharedPreferences.getInstance();
    final marked = prefs.getBool(SetupScreen.setupDoneKey) ?? false;
    if (marked) {
      if (mounted) setState(() => _setupDone = true);
      return;
    }
    _walletSub = ref.listenManual(walletsProvider, (prev, next) async {
      if (_setupDone != null) return;
      final wallets = next.valueOrNull;
      if (wallets == null) return;
      _walletSub?.close();
      if (wallets.isNotEmpty) {
        final p = await SharedPreferences.getInstance();
        await p.setBool(SetupScreen.setupDoneKey, true);
        if (mounted) setState(() => _setupDone = true);
      } else {
        if (mounted) setState(() => _setupDone = false);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final done = _setupDone;
    if (done == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return done ? const AppShell() : const SetupScreen();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    SavingsScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Celengan'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Wawasan'),
        ],
      ),
    );
  }
}
