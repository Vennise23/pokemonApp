import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math'; // Import for random number generation
import 'pokemon_gallery.dart';
import 'game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<Map<String, dynamic>> pokemonData =
      []; // Initialize with an empty list
  bool isLoading = true; // Add a loading state
  bool showNotification = false; // Track whether to show the notification
  double highestScore = 0;
  double currentScore = 0;
  Key gamePageKey = UniqueKey(); // Unique key for GamePage
  final random = Random(); // Random number generator
  final player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _initializePokemonData(); // Initialize Pokémon data
    player.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _playAudio() async {
    if (!kIsWeb) {
      await player.setSource(AssetSource('sounds/pixel_party.mp3'));
      await player.resume();
    }
  }

  void _refreshGamePage() {
    setState(() {
      for (var pokemon in pokemonData) {
        Offset oldPosition = pokemon['position'];
        pokemon['position'] = Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          oldPosition.dy,
        ); // Randomize position
      }
      currentScore = 0;
      // Generate a new unique key to refresh the GamePage
      gamePageKey = UniqueKey();
    });
  }

  void _initializePokemonData() async {
    // Defer MediaQuery-dependent logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width; // Get screen width
      final random = Random();

      setState(() {
        pokemonData = [
          {
            'id': 0,
            'type': 'pokemon',
            'name': 'Balbasaur',
            'image': 'assets/images/pokemon_01c.png',
            'uImage': 'assets/images/pokemon_01a.png',
            'cImage': 'assets/images/pokemon_01b.png',
            'position': Offset(random.nextDouble() * screenWidth, 100),
            'text':
                'It roared like a beast… and sneezed glitter. I’m confused too.',
            'height': '0.7 m',
            'weight': '6.9 kg',
            'description':
                'Graduated from the Pokémon University with a degree in "Business". 5 years of experience in the Pokémon industry.',
            'color': Colors.lightBlue,
            'collected': false,
            'using': false,
          },
          {
            'id': 1,
            'type': 'pokemon',
            'name': 'Charmander',
            'image': 'assets/images/pokemon_02c.png',
            'uImage': 'assets/images/pokemon_02a.png',
            'cImage': 'assets/images/pokemon_02b.png',
            'text':
                'I think the Pokéball compressed it too much... why not ask professor to make a larger pokéball?',
            'height': '0.6 m',
            'weight': '8.5 kg',
            'description':
                'Single, No Money, No Love, No Life, only working for eat. 2 years of experience in the selling "Fried Grass".',
            'color': Colors.redAccent,
            'position': Offset(random.nextDouble() * screenWidth, -200),
            'collected': false,
            'using': false,
          },
          {
            'id': 2,
            'type': 'pokemon',
            'name': 'Chikorita',
            'image': 'assets/images/pokemon_03c.png',
            'uImage': 'assets/images/pokemon_03a.png',
            'cImage': 'assets/images/pokemon_03b.png',
            'text':
                'It’s like a walking, talking, and slightly confused marshmallow.',
            'height': '0.8 m',
            'weight': '7.5 kg',
            'description':
                'Phd Student in Pokémon Star University. 3 years of experience in the "Pokémon Research". Owned nothing but university aircon.',
            'color': Colors.greenAccent,
            'position': Offset(random.nextDouble() * screenWidth, -400),
            'collected': false,
            'using': false,
          },
          {
            'id': 3,
            'type': 'pokemon',
            'name': 'Squirtle',
            'image': 'assets/images/pokemon_04c.png',
            'uImage': 'assets/images/pokemon_04a.png',
            'cImage': 'assets/images/pokemon_04b.png',
            'text': 'This must be the beta version… it’s still rendering.',
            'height': '0.5 m',
            'weight': '9.0 kg',
            'description':
                'Graduated from the Pokémon University with a degree in "Business". 5 years of experience in the Pokémon industry.',
            'color': Colors.blueGrey,
            'position': Offset(random.nextDouble() * screenWidth, -500),
            'collected': false,
            'using': false,
          },
          {
            'id': 4,
            'type': 'pokemon',
            'name': 'Pikachu',
            'image': 'assets/images/pokemon_05c.png',
            'uImage': 'assets/images/pokemon_05a.png',
            'cImage': 'assets/images/pokemon_05b.png',
            'text':
                "The Pokédex says it's rare. But I think it just got lost on its way to the Pokémon Center.",
            'height': '0.4 m',
            'weight': '6.0 kg',
            'description':
                'Currently freelancing as a “Wild Pokémon Consultant.” Mostly just hiding in bushes.',
            'color': Colors.amber,
            'position': Offset(random.nextDouble() * screenWidth, -600),
            'collected': false,
            'using': false,
          },
          {
            'id': 5,
            'type': 'pokemon',
            'name': 'Growlithe',
            'image': 'assets/images/pokemon_06c.png',
            'uImage': 'assets/images/pokemon_06a.png',
            'cImage': 'assets/images/pokemon_06b.png',
            'text':
                "It charged at me with fire and fury... now it just looks like a wet chicken nugget.",
            'height': '1.6 m',
            'weight': '35.0 kg',
            'description':
                'Interned at Team Rocket. Got fired for cooking too many hot dogs.',
            'color': Colors.brown,
            'position': Offset(random.nextDouble() * screenWidth, -800),
            'collected': false,
            'using': false,
          },
          {
            'id': 6,
            'type': 'pokemon',
            'name': 'Bellsprout',
            'image': 'assets/images/pokemon_07c.png',
            'uImage': 'assets/images/pokemon_07a.png',
            'cImage': 'assets/images/pokemon_07b.png',
            'text': "I swear it looked cooler in the tall grass...",
            'height': '0.7 m',
            'weight': '4.0 kg',
            'description':
                'Runs a part-time business selling suspicious berries. Definitely not poison. Probably.',
            'color': Colors.lightGreen,
            'position': Offset(random.nextDouble() * screenWidth, -1000),
            'collected': false,
            'using': false,
          },
          {
            'id': 7,
            'type': 'pokemon',
            'name': 'Voltorb',
            'image': 'assets/images/pokemon_08c.png',
            'uImage': 'assets/images/pokemon_08a.png',
            'cImage': 'assets/images/pokemon_08b.png',
            'text':
                "It might be a Voltorb… or something else. Anyway, I named it ZapKobe.",
            'height': '0.5 m',
            'weight': '10.0 kg',
            'description':
                'Have 16 ex-girlfriends. 4 ex-wife. 24 marriages. 10 kids. 5 dog. 9 cats. 1 hamster.',
            'color': Colors.deepOrange,
            'position': Offset(random.nextDouble() * screenWidth, -1200),
            'collected': false,
            'using': false,
          },
        ];
        isLoading = false; // Set loading to false after data is ready
      });
    });
  }

  void _handlePokemonSelected(int index) {
    setState(() {
      // Set all Pokémon's "using" status to false
      for (var pokemon in pokemonData) {
        pokemon['using'] = false;
      }
      // Set the selected Pokémon's "using" status to true
      pokemonData[index]['using'] = true;
    });
  }

  void updateScore(double newScore) {
    setState(() {
      if (newScore > currentScore) {
        currentScore = newScore.round().toDouble(); // Update the highest score
      }
      if (newScore > highestScore) {
        highestScore = newScore.round().toDouble(); // Update the highest score
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show a loading indicator while waiting for Pokémon data
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Render the main UI after Pokémon data is ready
    return Scaffold(
      body: Stack(
        children: [
          GamePage(
            key: gamePageKey,
            pokemonData: pokemonData, // Pass Pokémon data to GamePage
            onPokemonCollected: (index) {
              setState(() {
                // Update only the specific Pokémon's collected status
                pokemonData[index]['collected'] = true;

                // Add notification (red dot on top right)on button icon
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    showNotification = true;
                  });
                });
              });
            },
            onScoreUpdated: updateScore,
          ),
          // Score Display
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Text(
                    'Score: $currentScore',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  Text(
                    'High Score: $highestScore',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Music Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                _playerState == PlayerState.playing
                    ? Icons.music_note
                    : Icons.music_off,
                color: Colors.white,
              ),
              onPressed: () async {
                if (player.state == PlayerState.playing) {
                  await player.pause();
                } else {
                  if (kIsWeb) {
                    await player.setSourceUrl('assets/sounds/pixel_party.mp3');
                  } else {
                    await player.setSource(
                      AssetSource('sounds/pixel_party.mp3'),
                    );
                  }
                  await player.resume();
                }
              },
            ),
          ),
          // Refresh Button
          Positioned(
            top: 40,
            left: 60,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshGamePage, // Call the refresh function
            ),
          ),
          // Book Icon Button
          Positioned(
            top: 40,
            right: 20,
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.book, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      showNotification = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PokemonGallery(
                              pokemonData: pokemonData,
                              onPokemonSelected: _handlePokemonSelected,
                            ),
                      ),
                    );
                  },
                ),
                if (showNotification) // Show notification if true
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
