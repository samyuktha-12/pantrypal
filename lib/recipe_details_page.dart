import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailsPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe["name"])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe["imageUrl"], height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(
              recipe["name"],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Cuisine: ${recipe["cuisine"]}"),
            SizedBox(height: 8),
            Text("Time: ${recipe["totalTimeInMins"]} mins"),
            SizedBox(height: 16),
            Text(
              "Ingredients:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var ingredient in recipe["ingredients"]) Text("- $ingredient"),
            SizedBox(height: 16),
            Text(
              "Instructions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(recipe["instructions"]),
          ],
        ),
      ),
    );
  }
}
