import 'package:flutter/material.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';

class MoodSelectionWidget extends StatelessWidget {
  final int selectedScore;
  final ValueChanged<int> onScoreSelected;

  const MoodSelectionWidget({
    super.key,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  static const List<Map<String, dynamic>> _moods = [
    {'emoji': '😭', 'score': 2, 'label': 'Muy mal'},
    {'emoji': '😔', 'score': 4, 'label': 'Mal'},
    {'emoji': '😐', 'score': 6, 'label': 'Neutral'},
    {'emoji': '🙂', 'score': 8, 'label': 'Bien'},
    {'emoji': '😁', 'score': 10, 'label': 'Muy bien'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _moods.map((mood) {
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
