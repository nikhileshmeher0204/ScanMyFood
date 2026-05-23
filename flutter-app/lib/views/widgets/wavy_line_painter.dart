import 'dart:math';

import 'package:flutter/material.dart';

class WavyLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  WavyLinePainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = 8.0; // Amplitude of the wave
    final waveLength = 20.0; // Length of one wave cycle

    path.moveTo(size.width / 2, 0);

    for (double y = 0; y <= size.height; y += 1) {
      final x = size.width / 2 + waveHeight * sin((y / waveLength) * 2 * pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
