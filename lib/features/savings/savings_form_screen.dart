import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/image_storage.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/savings_repository.dart';

class SavingsFormScreen extends ConsumerStatefulWidget {
  const SavingsFormScreen({super.key, this.goal, this.scrollController});
  final SavingsGoal? goal;
  final ScrollController? scrollController;

  static Future<void> show(BuildContext context, {SavingsGoal? goal}) {
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
        builder: (context, scrollController) => SavingsFormScreen(goal: goal, scrollController: scrollController),
      ),
    );
  }

  @override
  ConsumerState<SavingsFormScreen> createState() => _SavingsFormScreenState();
}

class _SavingsFormScreenState extends ConsumerState<SavingsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  DateTime? _deadline;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _nameCtrl.text = g.name;
      _purposeCtrl.text = g.purpose;
      _targetCtrl.text = g.targetAmount.toString();
      _deadline = g.deadline;
      _imagePath = g.imagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _purposeCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.goal == null ? 'Buat Celengan' : 'Edit Celengan', style: tt.titleLarge)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                        image: _imagePath != null && File(_imagePath!).existsSync()
                            ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imagePath == null
                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 36, color: cs.onSurfaceVariant), const SizedBox(height: 8), Text('Tambah gambar target', style: TextStyle(color: cs.onSurfaceVariant))])
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama celengan'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purposeCtrl,
                    decoration: const InputDecoration(labelText: 'Tujuan / deskripsi'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _targetCtrl,
                    decoration: const InputDecoration(labelText: 'Target nominal (Rp)', prefixText: 'Rp '),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').replaceAll('.', '').replaceAll(',', ''));
                      if (n == null || n <= 0) return 'Target harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tenggat (opsional)'),
                    subtitle: Text(_deadline == null ? 'Tidak ada tenggat' : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_deadline != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _deadline = null)),
                      Icon(Icons.calendar_today, color: cs.onSurfaceVariant),
                    ]),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2100));
                      if (d != null) setState(() => _deadline = d);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Menyimpan...' : 'Simpan')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final savedPath = await ImageStorage.saveImage(File(picked.path));
    if (mounted) setState(() => _imagePath = savedPath);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = SavingsRepository(ref.read(databaseProvider));
    final target = int.parse(_targetCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    final g = widget.goal;
    if (g == null) {
      await repo.createGoal(
        name: _nameCtrl.text.trim(),
        purpose: _purposeCtrl.text.trim(),
        targetAmount: target,
        deadline: _deadline,
        imagePath: _imagePath,
      );
    } else {
      await repo.updateGoal(
        g,
        name: _nameCtrl.text.trim(),
        purpose: _purposeCtrl.text.trim(),
        targetAmount: target,
        deadline: _deadline,
        clearDeadline: _deadline == null,
        imagePath: _imagePath,
        clearImage: _imagePath == null,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
