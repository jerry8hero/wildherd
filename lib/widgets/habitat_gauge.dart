import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 环境仪表盘组件 - 显示温度或湿度
class HabitatGauge extends StatelessWidget {
  final String label;
  final double value;
  final double minValue;
  final double maxValue;
  final double? idealMin;
  final double? idealMax;
  final String unit;
  final double size;

  const HabitatGauge({
    super.key,
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.idealMin,
    this.idealMax,
    required this.unit,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final color = _getColor(percentage);

    return SizedBox(
      width: size,
      height: size + 30,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _GaugePainter(
                percentage: percentage,
                color: color,
                backgroundColor: Colors.grey[200]!,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: size / 4,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: size / 8,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(double percentage) {
    if (idealMin != null && idealMax != null) {
      final idealPercentageMin = ((idealMin! - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
      final idealPercentageMax = ((idealMax! - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

      if (percentage >= idealPercentageMin && percentage <= idealPercentageMax) {
        return Colors.green;
      } else if ((percentage - idealPercentageMin).abs() < 0.15 || (percentage - idealPercentageMax).abs() < 0.15) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    // 默认颜色渐变
    if (percentage < 0.3) {
      return Colors.blue;
    } else if (percentage < 0.7) {
      return Colors.green;
    } else if (percentage < 0.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // 背景弧
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // 进度弧
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

/// 评分进度条组件
class ScoreProgressBar extends StatelessWidget {
  final String label;
  final double score;
  final Color? color;

  const ScoreProgressBar({
    super.key,
    required this.label,
    required this.score,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color ?? _getScoreColor(score)),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${score.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? _getScoreColor(score),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// 综合评分圆形指示器
class OverallScoreCircle extends StatelessWidget {
  final double score;
  final double size;

  const OverallScoreCircle({
    super.key,
    required this.score,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getScoreColor(score).withValues(alpha: 0.1),
        border: Border.all(
          color: _getScoreColor(score),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(0),
              style: TextStyle(
                fontSize: size / 2.5,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
            Text(
              '分',
              style: TextStyle(
                fontSize: size / 6,
                color: _getScoreColor(score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
