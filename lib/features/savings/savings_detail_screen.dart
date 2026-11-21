import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/utils/currency_format.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/savings_repository.dart';
import '../../shared/widgets/app_bar_back_button.dart';
import 'savings_form_screen.dart';

class SavingsDetailScreen extends ConsumerWidget {
  const SavingsDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider).valueOrNull ?? [];
    final goal = goals.where((g) => g.id == goalId).firstOrNull;
    if (goal == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Celengan tidak ditemukan')));
    }
    final entries = ref.watch(savingsEntriesProvider(goalId)).valueOrNull ?? [];
    final saved = entries.fold<int>(0, (s, e) => s + e.amount);
    final target = goal.targetAmount;
    final remaining = (target - saved).clamp(0, target);
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final eta = _calcEta(entries, remaining);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(goal.name),
            leading: const AppBarBackButton(),
            leadingWidth: 60,
            actions: [
              _AppBarActionGroup(
                actions: [
                  _AppBarActionItem(icon: Icons.edit_outlined, onPressed: () => SavingsFormScreen.show(context, goal: goal)),
                  _AppBarActionItem(icon: Icons.delete_outline, onPressed: () => _deleteGoal(context, ref, goal)),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(offset: Offset(0, (1 - value) * 16), child: child),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (goal.imagePath != null && File(goal.imagePath!).existsSync())
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(File(goal.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: cs.primaryContainer.withValues(alpha: 0.35),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goal.purpose.isNotEmpty) ...[
                              Text(goal.purpose, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 12),
                            ],
                            Text('Terkumpul', style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: saved.toDouble()),
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => Text(
                                CurrencyFormat.idr(v.round()),
                                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                              ),
                            ),
                            Text('dari ${CurrencyFormat.idr(target)}', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: v,
                                  minHeight: 12,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(cs.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${(progress * 100).toStringAsFixed(1)}% tercapai', style: tt.labelLarge),
                                Text('Sisa ${CurrencyFormat.idr(remaining)}', style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(14)),
                              child: Icon(Icons.schedule, color: cs.onTertiaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Perkiraan tercapai', style: tt.titleSmall),
                                  const SizedBox(height: 2),
                                  Text(eta, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                  if (goal.deadline != null)
                                    Text('Tenggat: ${DateFormat('dd MMM yyyy', 'id_ID').format(goal.deadline!)}',
                                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _showEntryDialog(context, ref, goal, deposit: true),
                            icon: const Icon(Icons.add),
                            label: const Text('Setor'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showEntryDialog(context, ref, goal, deposit: false),
                            icon: const Icon(Icons.remove),
                            label: const Text('Tarik'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('Riwayat', style: tt.titleMedium),
                  ),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Belum ada setoran.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    )
                  else
                    ...entries.asMap().entries.map((mapEntry) {
                      final i = mapEntry.key;
                      final e = mapEntry.value;
                      final isDeposit = e.amount >= 0;
                      final color = isDeposit ? AppColors.income : AppColors.expense;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(e.id),
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 280 + (i.clamp(0, 8) * 35)),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, child) => Opacity(
                          opacity: v,
                          child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(isDeposit ? Icons.south_west : Icons.north_east, color: color, size: 20),
                          ),
                          title: Text('${isDeposit ? '+' : '-'}${CurrencyFormat.idr(e.amount.abs())}',
                              style: tt.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                          subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(e.date)),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calcEta(List<SavingsEntry> entries, int remaining) {
    if (remaining <= 0) return 'Target tercapai!';
    final deposits = entries.where((e) => e.amount > 0).toList();
    if (deposits.length < 3) return 'Belum cukup data';
    final totalDeposit = deposits.fold<int>(0, (s, e) => s + e.amount);
    final firstDate = deposits.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final days = DateTime.now().difference(firstDate).inDays.clamp(1, 36500);
    final avgPerDay = totalDeposit / days;
    if (avgPerDay <= 0) return 'Belum cukup data';
    final daysLeft = (remaining / avgPerDay).ceil();
    final etaDate = DateTime.now().add(Duration(days: daysLeft));
    return DateFormat('dd MMM yyyy', 'id_ID').format(etaDate);
  }

  Future<void> _showEntryDialog(BuildContext context, WidgetRef ref, SavingsGoal goal, {required bool deposit}) async {
    final ctrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      sheetAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 400), reverseDuration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(deposit ? 'Setor' : 'Tarik', style: tt.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixText: 'Rp '),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan'))),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (ok != true) return;
    final amount = int.tryParse(ctrl.text.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    await SavingsRepository(ref.read(databaseProvider)).addEntry(
      goalId: goal.id,
      amount: deposit ? amount : -amount,
      date: DateTime.now(),
    );
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
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
                Text('Hapus celengan?', style: tt.titleLarge),
                const SizedBox(height: 8),
                Text('Semua riwayat setoran juga akan dihapus.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
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
      await SavingsRepository(ref.read(databaseProvider)).deleteGoal(goal.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _AppBarActionItem {
  const _AppBarActionItem({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
}

class _AppBarActionGroup extends StatelessWidget {
  const _AppBarActionGroup({required this.actions});
  final List<_AppBarActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            InkWell(
              onTap: actions[i].onPressed,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(actions[i].icon, size: 22, color: cs.onSurface),
              ),
            ),
            if (i != actions.length - 1)
              Container(width: 1, height: 20, color: cs.outlineVariant.withValues(alpha: 0.35)),
          ],
        ],
      ),
    );
  }
}
