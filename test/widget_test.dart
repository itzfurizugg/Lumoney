import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumoney/app/app.dart';
import 'package:lumoney/data/database/app_database.dart';
import 'package:lumoney/data/providers.dart';

void main() {
  testWidgets('App boots and shows navigation', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'setup_done': true});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletsProvider.overrideWith((ref) => Stream.value(<Wallet>[])),
          categoriesProvider.overrideWith((ref) => Stream.value(<Category>[])),
          transactionsProvider.overrideWith((ref) => Stream.value(<Transaction>[])),
          savingsGoalsProvider.overrideWith((ref) => Stream.value(<SavingsGoal>[])),
        ],
        child: const LumoneyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Transaksi'), findsWidgets);
    expect(find.text('Celengan'), findsWidgets);
    expect(find.text('Wawasan'), findsWidgets);
  });
}