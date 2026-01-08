import 'package:flutter/material.dart';

/// Custom painter for QR pattern placeholder
class QRPatternPainter extends CustomPainter {
  final Color color;

  QRPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final cellSize = size.width / 7;

    // Draw position markers (corners)
    _drawPositionMarker(canvas, Offset(0, 0), cellSize, paint);
    _drawPositionMarker(
      canvas,
      Offset(size.width - cellSize * 2.5, 0),
      cellSize,
      paint,
    );
    _drawPositionMarker(
      canvas,
      Offset(0, size.height - cellSize * 2.5),
      cellSize,
      paint,
    );

    // Draw center pattern
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    // Draw timing patterns
    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(4.5 * cellSize, i * cellSize, cellSize, cellSize),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, 4.5 * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  void _drawPositionMarker(
    Canvas canvas,
    Offset position,
    double cellSize,
    Paint paint,
  ) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(position.dx, position.dy, cellSize * 2.5, cellSize * 2.5),
      paint,
    );

    // Inner square (white background)
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx + cellSize * 0.5,
        position.dy + cellSize * 0.5,
        cellSize * 1.5,
        cellSize * 1.5,
      ),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    // Center square
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx + cellSize,
        position.dy + cellSize,
        cellSize * 0.5,
        cellSize * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(QRPatternPainter oldDelegate) => false;
}
