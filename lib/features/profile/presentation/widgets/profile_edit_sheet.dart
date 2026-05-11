import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';

/// BottomSheet genérico para editar un campo de texto del perfil.
Future<void> showProfileEditSheet({
  required BuildContext context,
  required String title,
  required String hint,
  required String initialValue,
  required Future<void> Function(String value) onSave,
  TextInputType keyboardType = TextInputType.text,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditSheet(
      title: title,
      hint: hint,
      initialValue: initialValue,
      onSave: onSave,
      keyboardType: keyboardType,
    ),
  );
}

class _EditSheet extends StatefulWidget {
  final String title;
  final String hint;
  final String initialValue;
  final Future<void> Function(String) onSave;
  final TextInputType keyboardType;

  const _EditSheet({
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.onSave,
    required this.keyboardType,
  });

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_controller.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: EsColors.distress,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(EsSpacing.md),
      padding: EdgeInsets.only(bottom: bottomInset + EsSpacing.md),
      decoration: BoxDecoration(
        color: EsColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EsColors.surfaceElevated),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: EsColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: EsSpacing.lg),
            Text(widget.title, style: EsTypography.headlineMedium),
            const SizedBox(height: EsSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: widget.keyboardType,
              style: EsTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: EsTypography.bodyLarge.copyWith(color: EsColors.textSecondaryDark),
                filled: true,
                fillColor: EsColors.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: EsSpacing.md,
                  vertical: EsSpacing.sm + 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: EsColors.primaryBlue, width: 2),
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: EsSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EsColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar', style: EsTypography.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
