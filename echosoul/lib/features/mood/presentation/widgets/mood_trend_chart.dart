import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../domain/entities/mood_entry_entity.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodEntryEntity> entries;

  const MoodTrendChart({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Preparar datos de los últimos 7 días
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    });

    final List<double?> dataPoints = last7Days.map((date) {
      final dayEntries = entries.where((e) {
        return e.moodScore != null &&
            e.createdAt.year == date.year &&
            e.createdAt.month == date.month &&
            e.createdAt.day == date.day;
      }).toList();

      if (dayEntries.isEmpty) return null;

      final average = dayEntries.map((e) => e.moodScore!).reduce((a, b) => a + b) / dayEntries.length;
      return average;
    }).toList();

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(EsSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EsColors.surfaceDark,
            EsColors.surfaceElevated.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: EsColors.surfaceElevated.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tu tendencia semanal', style: EsTypography.labelLarge),
              Text(
                'Últimos 7 días',
                style: EsTypography.caption.copyWith(color: EsColors.neonCyan),
              ),
            ],
          ),
          const SizedBox(height: EsSpacing.lg),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _ChartPainter(
                    dataPoints: dataPoints,
                    labels: last7Days.map((d) => DateFormat('E', 'es_ES').format(d).toUpperCase()).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double?> dataPoints;
  final List<String> labels;

  _ChartPainter({required this.dataPoints, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final double spacing = size.width / (labels.length - 1);
    final double maxHeight = size.height - 20;

    // ── Dibujar cuadrícula horizontal (sutil) ────────────────
    final gridPaint = Paint()
      ..color = EsColors.surfaceElevated.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = (maxHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Pincel para la línea
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [EsColors.primaryBlue, EsColors.neonCyan],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Pincel para el área debajo (degradado suave)
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          EsColors.primaryBlue.withOpacity(0.2),
          EsColors.primaryBlue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final areaPath = Path();
    bool started = false;

    for (int i = 0; i < dataPoints.length; i++) {
      final score = dataPoints[i];
      if (score == null) {
        started = false;
        continue;
      }

      // Invertimos el score (10 arriba, 1 abajo)
      final y = maxHeight - ((score - 1) / 9 * maxHeight);
      final x = i * spacing;

      if (!started) {
        path.moveTo(x, y);
        areaPath.moveTo(x, maxHeight);
        areaPath.lineTo(x, y);
        started = true;
      } else {
        // Curva suave (Bezier)
        final prevScore = dataPoints[i - 1]!;
        final prevY = maxHeight - ((prevScore - 1) / 9 * maxHeight);
        final prevX = (i - 1) * spacing;
        
        path.cubicTo(
          prevX + spacing / 2, prevY,
          x - spacing / 2, y,
          x, y,
        );
        areaPath.cubicTo(
          prevX + spacing / 2, prevY,
          x - spacing / 2, y,
          x, y,
        );
      }
      
      // Si es el último punto o el siguiente es nulo, cerrar área
      if (i == dataPoints.length - 1 || dataPoints[i + 1] == null) {
        areaPath.lineTo(x, maxHeight);
        areaPath.close();
      }
    }

    // Dibujar área y línea
    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);

    // Dibujar puntos y etiquetas
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * spacing;
      
      // Etiqueta del día
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i][0], // Solo la inicial para minimalismo
          style: EsTypography.caption.copyWith(fontSize: 10, color: EsColors.textSecondaryDark),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 12));

      // Punto si hay dato
      if (dataPoints[i] != null) {
        final score = dataPoints[i]!;
        final y = maxHeight - ((score - 1) / 9 * maxHeight);
        
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(x, y),
          2,
          Paint()..color = EsColors.primaryBlue,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
