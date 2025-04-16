import 'package:flutter/material.dart';

class SlingshotStrings extends StatelessWidget {
  final Offset leftAnchor;
  final Offset rightAnchor;
  final Offset center;

  const SlingshotStrings({
    super.key,
    required this.leftAnchor,
    required this.rightAnchor,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SlingshotPainter(leftAnchor, rightAnchor, center),
      child: Container(), // Empty container to provide a canvas for painting
    );
  }
}

class SlingshotPainter extends CustomPainter {
  final Offset left;
  final Offset right;
  final Offset center;

  SlingshotPainter(this.left, this.right, this.center);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 8
          ..color = Colors.brown
          ..style = PaintingStyle.stroke;

    // Draw the slingshot strings
    canvas.drawLine(left, center, paint);
    canvas.drawLine(right, center, paint);
  }

  @override
  bool shouldRepaint(covariant SlingshotPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.left != left ||
        oldDelegate.right != right;
  }
}
