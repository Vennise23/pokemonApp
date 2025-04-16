import 'package:flutter/material.dart';
import 'bouncing_image.dart';
import 'pokemon_detail.dart'; // Import the PokemonDetail widget

class PokemonGallery extends StatelessWidget {
  final List<Map<String, dynamic>> pokemonData; // Accept Pokémon data
  final Function(int)
  onPokemonSelected; // Callback to update the "using" status

  const PokemonGallery({
    super.key,
    required this.pokemonData,
    required this.onPokemonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Gallery')),
      body: Stack(
        children: [
          // 🔹 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_02.png', // replace with your image path
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Main content on top
          Center(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.5,
              ),
              itemCount: pokemonData.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonData[index];
                return GestureDetector(
                  onTap: () {
                    if (pokemon['collected']) {
                      // Show the Pokémon detail pop-up
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) => PokemonDetail(pokemon: pokemon),
                      );
                    }
                  },
                  child: MouseRegion(
                    cursor:
                        pokemon['collected']
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Top half with background and foreground image
                          Expanded(
                            flex: 2,
                            child: Container(
                              color:
                                  pokemon['collected']
                                      ? pokemon['color']
                                      : Colors
                                          .grey, // Your background color here
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background image
                                  Opacity(
                                    opacity: 0.5,
                                    child: Image.asset(
                                      pokemon['collected']
                                          ? pokemon['image']
                                          : pokemon['uImage'], // background image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Foreground Pokémon image (e.g., cImage)
                                  Center(
                                    child: BouncingImage(
                                      imagePath:
                                          pokemon['collected']
                                              ? pokemon['cImage']
                                              : pokemon['uImage'],
                                      size: 150,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bottom half with text and button
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    pokemon['collected']
                                        ? pokemon['name']
                                        : '???',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    pokemon['collected']
                                        ? pokemon['text']
                                        : 'Collect me!',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
