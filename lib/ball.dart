import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Ball extends StatefulWidget {
  final Offset initialPosition; // Initial position of the ball
  final Offset dragOffset; // Drag offset passed from Slingshot
  final double ballMass; // Ball mass for velocity calculation
  final String imagePath; // Ball image path
  final Offset launchVelocity; // Scalar launch velocity
  final bool launched;
  final void Function(bool) onOffScreen;
  final void Function(Offset) onPositionUpdate;

  const Ball({
    super.key,
    required this.initialPosition,
    required this.dragOffset,
    required this.ballMass,
    required this.imagePath,
    required this.launchVelocity,
    required this.launched,
    required this.onOffScreen,
    required this.onPositionUpdate, // Add the new callback
  });

  @override
  State<Ball> createState() => BallState();
}

class BallState extends State<Ball> with TickerProviderStateMixin {
  late Offset prevPosition;
  late Offset position;
  late Offset velocity;
  late Ticker _ticker;
  int? countdown;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_update)..start();
    _resetBall();
  }

  @override
  void didUpdateWidget(covariant Ball oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.launched) {
      // Update position directly without calling setState
      position = widget.initialPosition;
    } else if (oldWidget.launched != widget.launched && widget.launched) {
      // Set the initial velocity when the ball is launched
      velocity = widget.launchVelocity; // Apply launch velocity
    }
  }

  void _resetBall() {
    position = widget.initialPosition; // Reset ball position
    velocity = Offset.zero; // Reset velocity

    // Stop the ticker if it's active
    if (_ticker.isActive) {
      _ticker.stop();
    }

    // Restart the ticker
    _ticker.start();
  }

  void _startCountdown() {
    setState(() {
      countdown = 3; // Start countdown from 3
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && countdown == 3) {
        setState(() {
          countdown = 2;
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && countdown == 2) {
        setState(() {
          countdown = 1;
        });
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && countdown == 1) {
        setState(() {
          countdown = null; // Hide countdown
          _resetBall();
          widget.onOffScreen(true);
        });
      }
    });
  }

  // Public method to reset the ball
  void resetBall() {
    _resetBall();
    widget.onOffScreen(true);
  }

  void stopAtPosition(Offset collisionPosition) {
    setState(() {
      velocity = Offset.zero; // Stop the ball
      position =
          collisionPosition; // Set the ball's position to the collision point
    });
  }

  void updateVelocity(Offset newVelocity) {
    setState(() {
      velocity = Offset(
        velocity.dx * newVelocity.dx,
        velocity.dy * newVelocity.dy,
      ); // Update the ball's velocity
    });
  }

  void _update(Duration elapsed) {
    setState(() {
      if (!widget.launched) {
        // Follow the dragOffset dynamically when not launched
        position = widget.initialPosition;
      } else {
        double dt = 1 / 60; // 60fps
        double gravity = 500; // Scaled for screen
        double friction = 0.996; // Friction factor to slow down the ball
        double bounceFriction = 0.8; // Energy loss on bounce
        prevPosition = position; // Store previous position

        // Apply gravity to the vertical velocity
        velocity = Offset(
          velocity.dx * friction, // Apply friction to horizontal velocity
          velocity.dy + gravity * dt, // Gravity affects vertical velocity
        );

        // Update position based on velocity
        position += velocity * dt;

        // Get screen dimensions
        final screenSize = MediaQuery.of(context).size;

        // Check for collisions with screen boundaries
        if (position.dx - 25 <= 0 || position.dx + 25 >= screenSize.width) {
          // Reverse horizontal velocity and apply bounce friction
          velocity = Offset(-velocity.dx * bounceFriction, velocity.dy);
          // Clamp position to prevent it from going out of bounds
          position = Offset(
            position.dx.clamp(25, screenSize.width - 25),
            position.dy,
          );
        }

        if (position.dy + 25 >= screenSize.height) {
          // Reverse vertical velocity and apply bounce friction
          velocity = Offset(velocity.dx, -velocity.dy * bounceFriction);
          // Clamp position to prevent it from going out of bounds
          position = Offset(
            position.dx,
            position.dy.clamp(25, screenSize.height - 25),
          );
        }

        // Stop the ball if the velocity is very small
        const double epsilon = 0.1;
        if (velocity.distance <= epsilon ||
            (velocity.dx.abs() <= epsilon && velocity.dy.abs() <= epsilon) ||
            (position - prevPosition).distance <= epsilon) {
          velocity = Offset.zero;
          if (countdown == null) {
            _startCountdown(); // Start the countdown
          }
        }

        // Notify the parent widget of the updated position
        widget.onPositionUpdate(position);

        // If the ball goes off-screen (bottom edge)
        if (position.dy > screenSize.height) {
          _resetBall();
          widget.onOffScreen(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the rotation angle based on horizontal velocity
    double rotationAngle = -velocity.dx * 0.5;

    return Positioned(
      left: position.dx - 25,
      top: position.dy - 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ball image with rotation
          Transform.rotate(
            angle: rotationAngle, // Keep rotation consistent with velocity
            child: Image.asset(widget.imagePath, width: 50, height: 50),
          ),
          // Countdown text displayed on top of the ball
          if (countdown != null)
            Positioned(
              top: -10, // Adjust the position to appear above the ball
              child: Text(
                '$countdown',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
