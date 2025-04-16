import 'package:flutter/material.dart';

class Slingshot extends StatelessWidget {
  final bool isDragging;
  final Offset dragOffset;
  final String slingshotImagePath;

  const Slingshot({
    super.key,
    required this.isDragging,
    required this.dragOffset,
    required this.slingshotImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final centerX = screenSize.width / 2;
    final bottomY = screenSize.height;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // Slingshot image
          Positioned(
            left: centerX - 50,
            top: bottomY - 200,
            child: Image.asset(slingshotImagePath, width: 100, height: 100),
          ),
        ],
      ),
    );
  }
}
