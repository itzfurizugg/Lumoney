import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../shared/widgets/app_bar_back_button.dart';

class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({super.key, this.wallet});
  final Wallet? wallet;

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0');
  String _icon = 'account_balance_wallet';
  int _color = 0xFF1565C0;
  bool _saving = false;

  static const _presets = <({String label, String icon, int color})>[
    (label: 'Cash', icon: 'payments', color: 0xFF2E7D32),
    (label: 'Bank', icon: 'account_balance', color: 0xFF1565C0),
    (label: 'E-Wallet', icon: 'account_balance_wallet', color: 0xFF00897B),
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    if (w != null) {
      _nameCtrl.text = w.name;
      _balanceCtrl.text = w.initialBalance.toString();
      _icon = w.icon;
      _color = w.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.wallet != null;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        leadingWidth: 60,
        title: Text(isEdit ? 'Edit Dompet' : 'Tambah Dompet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isEdit) ...[
              const Text('Tipe cepat', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _presets.map((p) {
                  final selected = _nameCtrl.text == p.label && _icon == p.icon;
                  return ChoiceChip(
                    label: Text(p.label),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _nameCtrl.text = p.label;
                      _icon = p.icon;
                      _color = p.color;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama dompet'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceCtrl,
              decoration: const InputDecoration(labelText: 'Saldo awal (Rp)', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').replaceAll('.', '').replaceAll(',', ''));
                if (n == null || n < 0) return 'Saldo tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Warna', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in [0xFF1565C0, 0xFF2E7D32, 0xFF00897B, 0xFFEF6C00, 0xFF6A1B9A, 0xFFC62828, 0xFF455A64])
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(c),
                      child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
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
    setState(() => _saving = true);
    final repo = WalletRepository(ref.read(databaseProvider));
    final balance = int.parse(_balanceCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    final w = widget.wallet;
    if (w == null) {
      await repo.create(name: _nameCtrl.text.trim(), icon: _icon, color: _color, initialBalance: balance);
    } else {
      await repo.updateWallet(w, name: _nameCtrl.text.trim(), icon: _icon, color: _color, initialBalance: balance);
    }
    if (mounted) Navigator.of(context).pop(true);
  }
}
