// Custom Painter Class
import 'package:flutter/material.dart';

// Updated Custom Painter Class
class DiagonalStrikeThroughPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double horizontalPadding; // Controls horizontal line length
  final double verticalPadding;   // Controls vertical line length

  DiagonalStrikeThroughPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.horizontalPadding = 0.0,
    this.verticalPadding = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Calculate start/end points with padding
    final start = Offset(horizontalPadding, size.height - verticalPadding);
    final end = Offset(size.width - horizontalPadding, verticalPadding);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}