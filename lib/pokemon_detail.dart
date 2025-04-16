import 'package:flutter/material.dart';

class PokemonDetail extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetail({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: pokemon['color'], // 🔹 Your background color
            borderRadius: BorderRadius.circular(
              16,
            ), // 🔁 Match the Card's radius
          ),
          padding: const EdgeInsets.all(16.0), // 👈 Actual content padding
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pokémon Image
                Image.asset(
                  pokemon['image'],
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                // Pokémon Name
                Text(
                  pokemon['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Pokémon Type
                Text(
                  'Type: ${pokemon['type']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Pokémon Height and Weight
                Text(
                  'Height: ${pokemon['height']} | Weight: ${pokemon['weight']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Pokémon Description
                Text(
                  pokemon['description'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
