import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double padding;
  final double lineLength; // Thêm thuộc tính mới

  CornerPainter({
    required this.radius,
    required this.color,
    this.padding = 10,
    this.lineLength = 30, // Độ dài mặc định của đường cong
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Path path = Path();

    // Góc trên bên trái
    path.moveTo(padding + lineLength, padding);
    path.lineTo(padding + radius, padding);
    path.quadraticBezierTo(padding, padding, padding, padding + radius);
    path.lineTo(padding, padding + lineLength);

    // Góc trên bên phải
    path.moveTo(size.width - padding - lineLength, padding);
    path.lineTo(size.width - padding - radius, padding);
    path.quadraticBezierTo(
        size.width - padding, padding, size.width - padding, padding + radius);
    path.lineTo(size.width - padding, padding + lineLength);

    // Góc dưới bên trái
    path.moveTo(padding, size.height - padding - lineLength);
    path.lineTo(padding, size.height - padding - radius);
    path.quadraticBezierTo(padding, size.height - padding, padding + radius,
        size.height - padding);
    path.lineTo(padding + lineLength, size.height - padding);

    // Góc dưới bên phải
    path.moveTo(size.width - padding, size.height - padding - lineLength);
    path.lineTo(size.width - padding, size.height - padding - radius);
    path.quadraticBezierTo(size.width - padding, size.height - padding,
        size.width - padding - radius, size.height - padding);
    path.lineTo(size.width - padding - lineLength, size.height - padding);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
