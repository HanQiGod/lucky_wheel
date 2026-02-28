import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 自定义绘制转盘
class LuckyWheelPainter extends CustomPainter {
  final List<String> prizeNames;
  final List<Color> prizeColors;
  final Color? sectionBorderColor;
  final double? sectionBorderWidth;
  final TextStyle? textStyle;
  final int? highlightedIndex;

  LuckyWheelPainter(
    this.prizeNames,
    this.prizeColors, {
    this.sectionBorderColor,
    this.sectionBorderWidth,
    this.textStyle,
    this.highlightedIndex,
  }) : super(repaint: AlwaysStoppedAnimation(true));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final anglePerSection = (math.pi * 2) / prizeNames.length;

    for (int i = 0; i < prizeNames.length; i++) {
      final startAngle = i * anglePerSection - math.pi / 2; // 从顶部开始
      final sweepAngle = anglePerSection;

      // 创建扇形路径
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      path.close();

      // 设置画笔
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = i == highlightedIndex
            ? prizeColors[i].withValues(alpha: 0.8)
            : prizeColors[i];

      canvas.drawPath(path, paint);

      // 绘制边框
      if (sectionBorderColor != null && sectionBorderWidth != null) {
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = sectionBorderColor!
          ..strokeWidth = sectionBorderWidth!;

        canvas.drawPath(path, borderPaint);
      }

      // 绘制文字
      _drawText(canvas, prizeNames[i], center, radius, startAngle, sweepAngle);
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, double radius,
      double startAngle, double sweepAngle) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle ??
          TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // 计算文字位置
    final midAngle = startAngle + sweepAngle / 2;
    final textRadius = radius * 0.6;
    final textX = center.dx + textRadius * math.cos(midAngle);
    final textY = center.dy + textRadius * math.sin(midAngle);

    final textOffset = Offset(
      textX - textPainter.width / 2,
      textY - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(LuckyWheelPainter oldDelegate) {
    return oldDelegate.prizeNames != prizeNames ||
        oldDelegate.prizeColors != prizeColors ||
        oldDelegate.sectionBorderColor != sectionBorderColor ||
        oldDelegate.sectionBorderWidth != sectionBorderWidth ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.highlightedIndex != highlightedIndex;
  }
}
