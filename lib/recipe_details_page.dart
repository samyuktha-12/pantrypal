import 'package:flutter/material.dart';
import 'chatbot_screen.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailsPage({required this.recipe});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  @override
  void initState() {
    super.initState(); // Necessary for Android
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe["name"],
          style: TextStyle(fontFamily: 'DancingScript', fontSize: 34.0),
        ),
        backgroundColor: Colors.teal, // Set AppBar to teal
      ),
      body: SingleChildScrollView(  // Added SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image covering entire width of the screen
              Image.network(
                widget.recipe["imageUrl"],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),

              // Name of the recipe, aligned to the center
              Text(
                widget.recipe["name"],
                textAlign: TextAlign.center, // Center-align the recipe name
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8, // Space between tiles
                runSpacing: 4, // Vertical space between tiles
                children: [
                  _buildInfoTile('Cuisine', widget.recipe["cuisine"]),
                  _buildInfoTile('Time', '${widget.recipe["totalTimeInMins"]} mins'),
                ],
              ),
              SizedBox(height: 16),

              // Ingredients in small tiles aligned horizontally
              Text(
                "Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8, // Space between tiles
                runSpacing: 4, // Vertical space between tiles
                children: widget.recipe["ingredients"]
                    .map<Widget>((ingredient) => _buildIngredientTile(ingredient))
                    .toList(),
              ),
              SizedBox(height: 16),

              // Instructions in a box
              Text(
                "Instructions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.recipe["instructions"],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button (Chat with Bot) at bottom-right corner
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
        backgroundColor: Colors.teal, // Button color
        child: Icon(Icons.chat, color: Colors.white), // Chat icon
      ),
    );
  }

  // Helper function to build small info tiles for Cuisine and Time
  Widget _buildInfoTile(String title, String content) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal, width: 1),
      ),
      child: Text(
        '$title: $content',
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  // Helper function to build ingredient tiles
  Widget _buildIngredientTile(String ingredient) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal, width: 1),
      ),
      child: Text(
        ingredient,
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}
