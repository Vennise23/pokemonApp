import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'bouncing_image.dart';
import 'dart:math';

class BarrierGenerator extends StatefulWidget {
  final double cameraOffset; // Current camera offset
  final double screenHeight; // Height of the screen
  final double screenWidth; // Width of the screen
  final List<Map<String, dynamic>> pokemonData; // Pokémon data
  final Offset ballPosition; // Ball position
  final double ballSize; // Ball size
  final void Function(Offset newVelocity) onBallCollision;
  final void Function(int pokemonIndex, Offset collisionPosition)
  onPokemonCollision;

  const BarrierGenerator({
    super.key,
    required this.cameraOffset,
    required this.screenHeight,
    required this.screenWidth,
    required this.pokemonData,
    required this.ballPosition,
    required this.ballSize,
    required this.onBallCollision,
    required this.onPokemonCollision,
  });

  @override
  State<BarrierGenerator> createState() => _BarrierGeneratorState();
}

class _BarrierGeneratorState extends State<BarrierGenerator>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> flyingBarriers = [];
  final List<Map<String, dynamic>> fixedPokemon = [];
  final double barrierSize = 50; // Size of each barrier (50px × 50px)
  final Random random = Random();
  late AnimationController _barrierAnimationController;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeFixedPokemon();
    _initializeFlyingBarriers();
    //Animation controller for flying barriers
    _barrierAnimationController =
        AnimationController(
            vsync: this,
            duration: const Duration(
              seconds: 5,
            ), // Barriers move across the screen in 5 seconds
          )
          ..addListener(() {
            _checkCollisions(); // Check for collisions during animation updates
          })
          ..repeat();
  }

  // // Initialize fixed Pokémon positions
  void _initializeFixedPokemon() {
    for (var pokemon in widget.pokemonData) {
      if (!pokemon['collected']) {
        fixedPokemon.add({
          'id': pokemon['id'],
          'type': pokemon['type'],
          'image': pokemon['image'],
          'position': pokemon['position'],
          'collected': pokemon['collected'],
        });
      }
    }
  }

  // Initialize flying barriers
  void _initializeFlyingBarriers() {
    // Use default values if screenHeight or screenWidth is invalid
    final double screenHeight =
        widget.screenHeight > 0 ? widget.screenHeight : 600.0;
    final double screenWidth =
        widget.screenWidth > 0 ? widget.screenWidth : 800.0;

    final int barriersPerRange = 5; // Minimum number of barriers per 400 pixels
    final double rangeHeight = 400; // Height of each range
    final Set<double> usedYPositions =
        {}; // Track used y positions to prevent overlap
    final Set<int> usedXLines = {}; // Track used x lines (50px width)

    // Calculate the number of ranges needed to cover the screen height
    final int numRanges = (screenHeight * 5 / rangeHeight).ceil();

    for (int range = 0; range < numRanges; range++) {
      final double rangeStartY = -range * rangeHeight;

      // Stop generating barriers if the rangeStartY exceeds -2000
      if (rangeStartY < -2000) break;

      for (int i = 0; i < barriersPerRange; i++) {
        double yPosition;
        int xLine;
        int maxAttempts =
            100; // Limit the number of attempts to prevent infinite loops

        // Ensure no overlap by generating a unique y position
        do {
          yPosition = rangeStartY + random.nextDouble() * rangeHeight;
          maxAttempts--;
          if (maxAttempts <= 0) break; // Exit if too many attempts
        } while (usedYPositions.contains(yPosition));

        if (maxAttempts <= 0)
          continue; // Skip this barrier if no valid position is found

        maxAttempts = 100; // Reset attempts for xLine

        // Ensure no overlap by generating a unique x line
        do {
          xLine = (random.nextDouble() * (screenWidth / 50)).floor();
          maxAttempts--;
          if (maxAttempts <= 0) break; // Exit if too many attempts
        } while (usedXLines.contains(xLine));

        if (maxAttempts <= 0)
          continue; // Skip this barrier if no valid x line is found

        usedYPositions.add(yPosition); // Mark this y position as used
        usedXLines.add(xLine); // Mark this x line as used

        // 60% chance to generate a fixed barrier
        if (random.nextDouble() < 0.6) {
          flyingBarriers.add({
            'type': 'fixed',
            'image': 'assets/images/block_01.png',
            'y': yPosition, // Unique y position
            'x': xLine * 50.0, // Unique x position (aligned to 50px grid)
            'health': 2, // Ensure health is initialized
          });
        } else {
          // 40% chance to generate a flying barrier
          flyingBarriers.add({
            'type': 'block',
            'image': 'assets/images/block_01.png',
            'y': yPosition, // Unique y position
            'x': xLine * 50.0, // Unique x position (aligned to 50px grid)
            'direction':
                random.nextBool()
                    ? 'left-to-right'
                    : 'right-to-left', // Random direction
            'delay': random.nextDouble(), // Random delay for movement
            'health': 2, // Ensure health is initialized
          });
        }
      }
    }
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

  void _checkCollisions() {
    for (int i = 0; i < fixedPokemon.length; i++) {
      final pokemon = fixedPokemon[i];

      // Skip already collected or colliding Pokémon
      if (pokemon['collected'] == true || pokemon['isColliding'] == true) {
        continue;
      }

      final pokemonRect = Rect.fromLTWH(
        pokemon['position'].dx,
        pokemon['position'].dy + widget.cameraOffset,
        50, // Pokémon size
        50,
      );

      final ballRect = Rect.fromCircle(
        center: widget.ballPosition,
        radius: widget.ballSize / 2,
      );

      if (pokemonRect.overlaps(ballRect)) {
        // Play sound
        _PlaySound('sounds/pokemon_caught.mp3');

        // Mark the Pokémon as colliding to prevent multiple callbacks
        setState(() {
          pokemon['collected'] = true;
          pokemon['isColliding'] = true;
        });

        // Notify the parent widget about the collision
        widget.onPokemonCollision(pokemon['id'], widget.ballPosition);

        // Stop further collision checks
        break;
      }
    }
    for (var barrier in flyingBarriers) {
      // Add a flag to track if the barrier is already hit
      barrier.putIfAbsent('isHit', () => false);
      // Ensure all required properties are non-null
      final double? barrierX = barrier['x'] as double?;
      final double? barrierY = barrier['y'] as double?;
      final double? delay = barrier['delay'] as double?;
      final int? health = barrier['health'] as int?;
      if (barrierX == null || barrierY == null || health == null) {
        continue; // Skip this barrier if any property is null
      }
      // Dynamically calculate the current x position of the flying barrier
      double currentXPosition;
      if (barrier['type'] == 'fixed') {
        currentXPosition = barrierX; // Fixed barriers use their x position
      } else {
        double animationValue =
            (_barrierAnimationController.value + (delay ?? 0)) % 1.0;
        if (barrier['direction'] == 'left-to-right') {
          // Move from left to right
          currentXPosition = animationValue * widget.screenWidth;
        } else {
          // Move from right to left
          currentXPosition =
              widget.screenWidth - (animationValue * widget.screenWidth);
        }
      }
      // Create the barrier rectangle with the dynamically calculated position
      final barrierRect = Rect.fromLTWH(
        currentXPosition - barrierSize / 2, // Adjust for barrier size
        barrierY + widget.cameraOffset,
        barrierSize,
        barrierSize,
      );
      final ballRect = Rect.fromCircle(
        center: widget.ballPosition, // Use widget.ballPosition
        radius: widget.ballSize / 2, // Use widget.ballSize
      );
      if (barrierRect.overlaps(ballRect)) {
        if (!barrier['isHit']) {
          // Process collision only if the barrier is not already hit
          setState(() {
            barrier['health'] = health - 1; // Reduce health on collision
            if (barrier['health'] == 1) {
              // Play sound
              _PlaySound('sounds/box_hit.mp3');
              barrier['image'] =
                  'assets/images/block_02.png'; // Change to damaged image
            } else if (barrier['health'] <= 0) {
              // Play sound
              _PlaySound('sounds/box_crash.mp3');
              flyingBarriers.remove(
                barrier,
              ); // Remove barrier after second collision
            }
          });
          // Calculate bounce direction
          Offset newVelocity;
          if (widget.ballPosition.dy < barrierRect.top ||
              widget.ballPosition.dy > barrierRect.bottom) {
            // Ball hit the top of the barrier
            newVelocity = Offset(1, -1); // Reverse vertical direction
          } else if (widget.ballPosition.dx < barrierRect.left ||
              widget.ballPosition.dx > barrierRect.right) {
            // Ball hit the left side of the barrier
            newVelocity = Offset(-1, 1); // Reverse horizontal direction
          } else {
            // Default case (e.g., corner collision)
            newVelocity = Offset(-1, -1); // Reverse both directions
          }
          // Apply bounce friction
          newVelocity = Offset(
            newVelocity.dx * 0.9, // Horizontal bounce friction
            newVelocity.dy * 0.9, // Vertical bounce friction
          );
          // Update the ball's velocity
          widget.onBallCollision(newVelocity);
          // Mark the barrier as hit
          barrier['isHit'] = true;
        }
      } else {
        // Reset the hit flag when the ball moves away
        barrier['isHit'] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove Pokemon from fixedPokemon once it is collected
    for (var pokemon in fixedPokemon) {
      if (pokemon['collected']) {
        fixedPokemon.remove(pokemon);
        break; // Exit the loop after removing the collected Pokémon
      }
    }
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none, // Prevent the Stack from clipping its children
        children: [
          // Render fixed Pokémon
          for (var pokemon in fixedPokemon)
            if (!pokemon['collected'])
              Positioned(
                left: pokemon['position'].dx,
                top: pokemon['position'].dy + widget.cameraOffset,
                child: BouncingImage(
                  imagePath: pokemon['image'],
                  size: barrierSize,
                ),
              ),

          // Render flying barriers
          for (var barrier in flyingBarriers)
            if (barrier['type'] == 'block')
              AnimatedBuilder(
                animation: _barrierAnimationController,
                builder: (context, child) {
                  double animationValue =
                      (_barrierAnimationController.value + barrier['delay']) %
                      1.0;
                  double xPosition;

                  if (barrier['direction'] == 'left-to-right') {
                    // Move from left to right
                    xPosition = animationValue * widget.screenWidth;
                  } else {
                    // Move from right to left
                    xPosition =
                        widget.screenWidth -
                        (animationValue * widget.screenWidth);
                  }

                  return Positioned(
                    left: xPosition - barrierSize, // Adjust x position
                    top:
                        barrier['y'] +
                        widget.cameraOffset, // Adjust for camera offset
                    child: Image.asset(
                      barrier['image'],
                      width: barrierSize,
                      height: barrierSize,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            else if (barrier['type'] == 'fixed')
              Positioned(
                left: barrier['x'],
                top: barrier['y'] + widget.cameraOffset,
                child: Image.asset(
                  barrier['image'],
                  width: barrierSize,
                  height: barrierSize,
                  fit: BoxFit.cover,
                ),
              ),
        ],
      ),
    );
  }
}
