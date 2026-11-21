import 'package:material_ui/material_ui.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Wawasan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(28)),
                child: Icon(Icons.insights, size: 48, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 20),
              Text('Wawasan akan hadir', style: tt.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Grafik cashflow, AI Wrapped, dan saran pengeluaran akan muncul di sini.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
