import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'slingshot.dart';
import 'ball.dart';
import 'slingshot_string.dart';
import 'barrier_generator.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  final List<Map<String, dynamic>> pokemonData; // Pokémon data
  final void Function(int) onPokemonCollected; // Callback for collected Pokémon
  final void Function(double) onScoreUpdated; // Callback for score updates

  const GamePage({
    super.key,
    required this.pokemonData,
    required this.onPokemonCollected,
    required this.onScoreUpdated,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Offset initialDragOffset = Offset.zero; // To track initial drag position
  Offset dragOffset = Offset.zero; // To track current drag position
  bool isDragging = false;
  double cameraOffset = 0; // Camera offset for scrolling
  bool ballLaunched = false; // To track if the ball has been launched
  double backgroundOffset = 0; // Background offset for slower movement
  double springConstant = 150; // Spring constant for slingshot
  double ballMass = 1.0; // Mass of the ball
  Offset currBallPosition = Offset.zero; // Ball's current position
  final player = AudioPlayer();

  Offset ballInitialPosition = Offset.zero; // Ball's initial position

  // GlobalKey to access the Ball widget's state
  final GlobalKey<BallState> ballKey = GlobalKey<BallState>();

  void _onBallPositionUpdate(Offset ballPosition) {
    setState(() {
      // Move the camera up if the ball moves upward past the top of the screen
      if (ballPosition.dy < MediaQuery.of(context).size.height / 2) {
        cameraOffset =
            (MediaQuery.of(context).size.height / 2 - ballPosition.dy);

        // Update the score based on camera offset
        widget.onScoreUpdated(cameraOffset);

        backgroundOffset += cameraOffset * 0.001;
        // Clamp the background offset to prevent it from moving past its top
        backgroundOffset = backgroundOffset.clamp(
          -MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.height,
        );

        currBallPosition = ballPosition; // Update the ball's position
        cameraOffset = cameraOffset.clamp(
          -MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.height,
        );
      }
    });
  }

  void _resetCamera() {
    setState(() {
      cameraOffset = 0; // Reset the camera to the original position
      backgroundOffset = 0; // Reset the background to its original position
    });
  }

  @override
  Widget build(BuildContext context) {
    Offset currDragOffset = isDragging ? dragOffset : Offset.zero;

    final Size screenSize = MediaQuery.of(context).size;

    // Calculate slingshot anchors
    final centerX = screenSize.width / 2;
    final bottomY = screenSize.height;
    final leftAnchor = Offset(centerX - 40, bottomY - 190);
    final rightAnchor = Offset(centerX + 40, bottomY - 190);

    // Calculate the center of the slingshot
    final center = Offset(
      (leftAnchor.dx + rightAnchor.dx) / 2 + currDragOffset.dx,
      (leftAnchor.dy + rightAnchor.dy) / 2 + currDragOffset.dy,
    );

    ballInitialPosition = center; // Update ball's initial position

    Offset calculateLaunchVelocity() {
      if (dragOffset == null || dragOffset.distance == 0) {
        return Offset.zero; // No launch velocity if no drag
      }
      double x = dragOffset.distance;
      double velocity = sqrt(springConstant / ballMass) * x * 0.001;

      // Normalize the dragOffset to get the direction
      Offset normalizedDirection = dragOffset / dragOffset.distance;

      // Return the velocity as an Offset in the opposite direction
      return Offset(
        velocity * -normalizedDirection.dx * 500,
        velocity * -normalizedDirection.dy * 500,
      );
    }

    void _PlaySound(String url) async {
      if (kIsWeb) {
        // For web, use the web player
        url = 'assets/' + url;
        await player.play(UrlSource(url));
      } else {
        // For mobile, use the default player
        await player.play(AssetSource(url));
      }
    }

    void handlePokemonCollision(int pokemonIndex, Offset collisionPosition) {
      // Notify the Ball widget to stop at the collision position
      ballKey.currentState?.stopAtPosition(collisionPosition);

      // Update the Pokémon's collected status
      setState(() {
        widget.pokemonData[pokemonIndex]['isColliding'] = false;
        widget.onPokemonCollected(pokemonIndex);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                isDragging = true;
                initialDragOffset =
                    details.localPosition; // Store the initial XY point
                dragOffset = details.localPosition - initialDragOffset;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                // Calculate the raw drag offset
                Offset rawDragOffset =
                    details.localPosition - initialDragOffset;

                // Clamp the drag offset to a maximum length of 400 pixels
                if (rawDragOffset.distance > 200) {
                  rawDragOffset = rawDragOffset / rawDragOffset.distance * 200;
                }

                dragOffset = rawDragOffset; // Apply scaling if needed
              });
            },
            onPanEnd: (_) {
              setState(() {
                isDragging = false;
                ballLaunched = true;
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 🌄 Background Image
                Positioned.fill(
                  child: OverflowBox(
                    alignment: Alignment.bottomCenter,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: Transform.translate(
                      offset: Offset(0, cameraOffset),
                      child: Image.asset(
                        'assets/images/background_01.png',
                        fit: BoxFit.cover,
                        height: screenSize.height * 2,
                        width: screenSize.width,
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, cameraOffset),
                    child: Stack(
                      clipBehavior:
                          Clip.none, // Prevent the Stack from clipping its children
                      children: [
                        // 🪃 Slingshot
                        Slingshot(
                          isDragging: isDragging,
                          dragOffset: isDragging ? dragOffset : Offset.zero,
                          slingshotImagePath: 'assets/images/slingshot_01.png',
                        ),

                        // 🎯 Ball
                        Ball(
                          key:
                              ballKey, // Assign the GlobalKey to the Ball widget
                          initialPosition: ballInitialPosition,
                          dragOffset: isDragging ? dragOffset : Offset.zero,
                          ballMass: ballMass,
                          imagePath: 'assets/images/ball_01.png',
                          launchVelocity: calculateLaunchVelocity(),
                          launched: ballLaunched,
                          onOffScreen: (bool reset) {
                            setState(() {
                              if (reset) {
                                ballLaunched = false;
                              }
                              _resetCamera();
                            });
                          },
                          onPositionUpdate: _onBallPositionUpdate,
                        ),

                        // 🎨 Slingshot Strings
                        SlingshotStrings(
                          leftAnchor: leftAnchor,
                          rightAnchor: rightAnchor,
                          center: center,
                        ),

                        // 🧱 Barrier Generator
                        BarrierGenerator(
                          cameraOffset: cameraOffset,
                          screenHeight: screenSize.height,
                          screenWidth: screenSize.width,
                          pokemonData: widget.pokemonData, // Pass Pokémon data
                          ballPosition: currBallPosition,
                          ballSize: 30,
                          onBallCollision: (Offset newVelocity) {
                            setState(() {
                              ballKey.currentState?.updateVelocity(
                                newVelocity,
                              ); // Update ball velocity
                            });
                          },
                          onPokemonCollision: handlePokemonCollision,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🟢 Reset Button
          if (ballLaunched)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: ElevatedButton(
                onPressed: () {
                  // Call the resetBall() method via the GlobalKey
                  ballKey.currentState?.resetBall();
                },
                child: const Text('Reset Ball'),
              ),
            ),
        ],
      ),
    );
  }
}
