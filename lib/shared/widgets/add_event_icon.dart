import 'package:flutter/material.dart';

class AddEventIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AddEventIcon({
    super.key,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: AddEventPainter(color: color),
    );
  }
}

class AddEventPainter extends CustomPainter {
  final Color color;

  AddEventPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw calendar body border
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 6, size.width - 4, size.height - 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Draw calendar binder loops (two small lines at the top)
    canvas.drawLine(
      Offset(size.width * 0.28, 2),
      Offset(size.width * 0.28, 8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 2),
      Offset(size.width * 0.72, 8),
      paint,
    );

    // Draw calendar header separator line
    canvas.drawLine(
      Offset(2, 14),
      Offset(size.width - 2, 14),
      paint,
    );

    // Draw a circular badge for the plus sign in the bottom-right part
    final badgeCenter = Offset(size.width * 0.7, size.height * 0.7);
    final badgeRadius = size.width * 0.24;

    // Clear the background behind the badge (with a black circle gap)
    final clearPaint = Paint()
      ..color = const Color(0xFF000000) // Screen black background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, badgeRadius + 1.5, clearPaint);

    // Draw badge border
    canvas.drawCircle(badgeCenter, badgeRadius, paint);

    // Draw plus sign inside the badge
    final plusSize = badgeRadius * 0.5;
    canvas.drawLine(
      Offset(badgeCenter.dx - plusSize, badgeCenter.dy),
      Offset(badgeCenter.dx + plusSize, badgeCenter.dy),
      paint,
    );
    canvas.drawLine(
      Offset(badgeCenter.dx, badgeCenter.dy - plusSize),
      Offset(badgeCenter.dx, badgeCenter.dy + plusSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
