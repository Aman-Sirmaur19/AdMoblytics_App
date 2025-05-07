import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomIndicatorPainter();
  }
}

class _CustomIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);

    final double width = configuration.size!.width;
    final double height = configuration.size!.height;

    final Rect glowRect = Rect.fromLTWH(
      offset.dx - width * 0.1, // Extend the glow to the sides
      offset.dy + height - 10, // Adjust position for the glow
      width * 1.2,
      20, // Height of the glow effect
    );

    // Draw the glow effect (blurred oval shape)
    canvas.drawOval(glowRect, paint);

    // Draw the default rounded indicator
    paint.color = Colors.blue;
    paint.maskFilter = null; // Remove blur for the default indicator

    // Create a path with rounded corners for the indicator
    final RRect roundedRect = RRect.fromLTRBR(
      offset.dx,
      offset.dy + height - 3, // Position of the indicator
      offset.dx + width,
      offset.dy + height + 3, // Bottom position of the indicator
      const Radius.circular(10), // Rounded corners
    );

    // Draw the indicator with rounded corners
    canvas.drawRRect(roundedRect, paint);
  }
}
