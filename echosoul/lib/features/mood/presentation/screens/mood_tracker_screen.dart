import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../shared/design_system/atoms/es_button.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selection_widget.dart';
import '../widgets/mood_trend_chart.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  int _selectedScore = 6; // Default to neutral
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    final label = switch (_selectedScore) {
      <= 2 => 'Muy mal',
      <= 4 => 'Mal',
      <= 6 => 'Neutral',
      <= 8 => 'Bien',
      _ => 'Muy bien',
    };

    await ref.read(moodProvider.notifier).saveEntry(
          score: _selectedScore,
          label: label,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado de ánimo guardado correctamente')),
      );
      _notesController.clear();
      setState(() {
        _selectedScore = 6;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodHistory = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      appBar: AppBar(
        title: const Text('¿Cómo te sientes?', style: EsTypography.headlineLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EsSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection Card
                Container(
                  padding: const EdgeInsets.all(EsSpacing.lg),
                  decoration: BoxDecoration(
                    color: EsColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      MoodSelectionWidget(
                        selectedScore: _selectedScore,
                        onScoreSelected: (score) => setState(() => _selectedScore = score),
                      ),
                      const SizedBox(height: EsSpacing.xl),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: EsTypography.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Añade una nota sobre cómo te sientes (opcional)...',
                          hintStyle: EsTypography.bodyMedium,
                          filled: true,
                          fillColor: EsColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: EsSpacing.lg),
                      EsButton(
                        label: 'Guardar estado',
                        onPressed: _saveMood,
                        isLoading: moodHistory.isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: EsSpacing.xxl),

                // History Section
                moodHistory.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: EsSpacing.xl),
                          child: Text(
                            'Aún no has registrado ningún estado.',
                            style: EsTypography.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MoodTrendChart(entries: history),
                        const SizedBox(height: EsSpacing.xxl),
                        const Text('Historial reciente', style: EsTypography.headlineMedium),
                        const SizedBox(height: EsSpacing.md),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: EsSpacing.sm),
                          itemBuilder: (context, index) {
                            final entry = history[index];
                            return Container(
                              padding: const EdgeInsets.all(EsSpacing.md),
                              decoration: BoxDecoration(
                                color: EsColors.surfaceDark,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(EsSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: EsColors.surfaceElevated,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      _getEmojiForScore(entry.moodScore),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(width: EsSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry.moodLabel ?? 'Sin etiqueta',
                                              style: EsTypography.labelLarge,
                                            ),
                                            Text(
                                              DateFormat('HH:mm, d MMM').format(entry.createdAt),
                                              style: EsTypography.caption,
                                            ),
                                          ],
                                        ),
                                        if (entry.notes != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.notes!,
                                            style: EsTypography.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, __) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEmojiForScore(int score) {
    return switch (score) {
      <= 2 => '😭',
      <= 4 => '😔',
      <= 6 => '😐',
      <= 8 => '🙂',
      _ => '😁',
    };
  }
}
