import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/currency_format.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'savings_detail_screen.dart';
import 'savings_form_screen.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Celengan')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(28)),
                      child: Icon(Icons.savings_outlined, size: 44, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    Text('Belum ada celengan', style: tt.titleLarge),
                    const SizedBox(height: 8),
                    Text('Buat target tabungan pertamamu.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }
          final totalSaved = goals.fold<int>(0, (sum, g) {
            final entries = ref.watch(savingsEntriesProvider(g.id)).valueOrNull ?? [];
            return sum + entries.fold<int>(0, (s, e) => s + e.amount);
          });
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                margin: EdgeInsets.zero,
                color: cs.primaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total terkumpul', style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(CurrencyFormat.idr(totalSaved), style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary)),
                      const SizedBox(height: 4),
                      Text('${goals.length} celengan aktif', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...goals.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GoalCard(goal: g),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SavingsFormScreen.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(savingsEntriesProvider(goal.id)).valueOrNull ?? [];
    final saved = entries.fold<int>(0, (s, e) => s + e.amount);
    final target = goal.targetAmount;
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final imagePath = goal.imagePath;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SavingsDetailScreen(goalId: goal.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath != null && File(imagePath).existsSync()
                    ? Image.file(File(imagePath), width: 76, height: 76, fit: BoxFit.cover)
                    : Container(
                        width: 76,
                        height: 76,
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.savings, color: cs.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${CurrencyFormat.compactIdr(saved)} / ${CurrencyFormat.compactIdr(target)}',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${(progress * 100).toStringAsFixed(0)}% tercapai', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
