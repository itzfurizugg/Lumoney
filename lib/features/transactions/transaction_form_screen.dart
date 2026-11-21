import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transaction, this.scrollController, this.initialType});
  final Transaction? transaction;
  final ScrollController? scrollController;
  final String? initialType;

  static Future<void> show(BuildContext context, {Transaction? transaction, String? initialType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      sheetAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 400), reverseDuration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => TransactionFormScreen(
          transaction: transaction,
          scrollController: scrollController,
          initialType: initialType,
        ),
      ),
    );
  }

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _type = 'expense';
  String? _walletId;
  String? _toWalletId;
  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.type;
      _titleCtrl.text = tx.title;
      _amountCtrl.text = tx.amount.toString();
      _noteCtrl.text = tx.note;
      _walletId = tx.walletId;
      _toWalletId = tx.toWalletId;
      _categoryId = tx.categoryId;
      _date = tx.date;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final filteredCategories = categories.where((c) => c.type == _type).toList();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (_walletId == null && wallets.isNotEmpty) _walletId = wallets.first.id;
    if (_type != 'transfer' && _categoryId != null && filteredCategories.every((c) => c.id != _categoryId)) {
      _categoryId = null;
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi', style: tt.titleLarge)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Keluar')),
                      ButtonSegment(value: 'income', label: Text('Masuk')),
                      ButtonSegment(value: 'transfer', label: Text('Transfer')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() {
                      _type = s.first;
                      _categoryId = null;
                      if (_type != 'transfer') _toWalletId = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').replaceAll('.', '').replaceAll(',', ''));
                      if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(_type == 'transfer' ? 'Dari dompet' : 'Dompet', style: tt.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in wallets)
                        ChoiceChip(
                          label: Text(w.name),
                          selected: _walletId == w.id,
                          onSelected: (_) => setState(() {
                            _walletId = w.id;
                            if (_toWalletId == w.id) _toWalletId = null;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_type == 'transfer') ...[
                    Text('Ke dompet', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final w in wallets.where((w) => w.id != _walletId))
                          ChoiceChip(
                            label: Text(w.name),
                            selected: _toWalletId == w.id,
                            onSelected: (_) => setState(() => _toWalletId = w.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text('Kategori', style: tt.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in filteredCategories)
                          ChoiceChip(
                            label: Text(c.name),
                            selected: _categoryId == c.id,
                            onSelected: (_) => setState(() => _categoryId = c.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal'),
                    subtitle: Text(DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_date)),
                    trailing: Icon(Icons.calendar_today, color: cs.onSurfaceVariant),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (d == null || !context.mounted) return;
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
                      if (!context.mounted) return;
                      setState(() => _date = DateTime(d.year, d.month, d.day, t?.hour ?? _date.hour, t?.minute ?? _date.minute));
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih dompet terlebih dahulu')));
      return;
    }
    if (_type == 'transfer' && _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih dompet tujuan')));
      return;
    }
    setState(() => _saving = true);
    final amount = int.parse(_amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    final repo = TransactionRepository(ref.read(databaseProvider));
    final tx = widget.transaction;
    if (tx == null) {
      await repo.create(
        type: _type,
        title: _titleCtrl.text.trim(),
        amount: amount,
        walletId: _walletId!,
        toWalletId: _type == 'transfer' ? _toWalletId : null,
        categoryId: _type == 'transfer' ? null : _categoryId,
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    } else {
      await repo.updateTransaction(
        tx,
        type: _type,
        title: _titleCtrl.text.trim(),
        amount: amount,
        walletId: _walletId!,
        toWalletId: _type == 'transfer' ? _toWalletId : null,
        clearToWalletId: _type != 'transfer',
        categoryId: _type == 'transfer' ? null : _categoryId,
        clearCategoryId: _type == 'transfer',
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
