import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import '../../../../l10n/app_localizations.dart';

class MoodSelectionWidget extends StatelessWidget {
  final int selectedScore;
  final ValueChanged<int> onScoreSelected;

  const MoodSelectionWidget({
    super.key,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  List<Map<String, dynamic>> _getMoods(BuildContext context) {
    return [
      {'emoji': '😭', 'score': 2, 'label': S.of(context).moodVeryBad},
      {'emoji': '😔', 'score': 4, 'label': S.of(context).moodBad},
      {'emoji': '😐', 'score': 6, 'label': S.of(context).moodNeutral},
      {'emoji': '🙂', 'score': 8, 'label': S.of(context).moodGood},
      {'emoji': '😁', 'score': 10, 'label': S.of(context).moodVeryGood},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final moods = _getMoods(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: moods.map((mood) {
          final isSelected = selectedScore == mood['score'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: EsInteractive(
              onTap: () => onScoreSelected((mood['score'] as num).toInt()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? EsColors.primaryBlue.withOpacity(0.2) : EsColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? EsColors.primaryBlue : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: EsColors.primaryBlue.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood['label'] as String,
                    style: TextStyle(
                      color: isSelected ? EsColors.textPrimaryDark : EsColors.textSecondaryDark,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
