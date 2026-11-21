import 'package:material_ui/material_ui.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Center(
        child: Material(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.35)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.pop(context),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back, size: 22, color: cs.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
