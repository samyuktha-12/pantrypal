import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'meal_planner.dart';
import 'fridge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details_page.dart';
import 'chatbot_screen.dart';
import 'recipe_generator.dart';

// Define Recipe Model
class Recipe {
  final String name;
  final List<String> ingredients;
  final int totalTimeInMins;
  final String cuisine;
  final String instructions;
  final String url;
  final String imageUrl;
  final int ingredientCount;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.totalTimeInMins,
    required this.cuisine,
    required this.instructions,
    required this.url,
    required this.imageUrl,
    required this.ingredientCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients,
      'totalTimeInMins': totalTimeInMins,
      'cuisine': cuisine,
      'instructions': instructions,
      'imageUrl': imageUrl,
    };
  }
}

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> recipes = []; // Initialize the recipes list
  List<Recipe> availableRecipes = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    loadRecipes();
    //fetchFridgeIngredients();
    //getDishesThatCanBeMade(recipes, fridgeIngredients) // Load recipes on widget initialization
  }

  Future<List<Recipe>> loadRecipes() async {
    List<Recipe> loadedRecipes = []; // Initialize an empty list

    try {
      // Fetch data from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recipes') // The Firestore collection name
          .get();

      // Debugging: Log the number of documents retrieved
      print("Snapshot retrieved: ${snapshot.docs.length} documents.");

      // Loop through the documents and map to Recipe objects
      for (var doc in snapshot.docs) {
        try {
          // Safely parse document data
          final data = doc.data() as Map<String, dynamic>;

          // Create a Recipe object
          Recipe recipe = Recipe(
            name: doc.id ?? 'Unknown',
            ingredients: (data['Cleaned-Ingredients'] as String?)
                    ?.split(',')
                    .map((e) => e.trim())
                    .toList() ??
                [], // Default to empty list
            totalTimeInMins: data['TotalTimeInMins'] ?? 0,
            cuisine: data['Cuisine'] ?? 'Unknown',
            instructions:
                data['TranslatedInstructions'] ?? 'No instructions available',
            url: data['URL'] ?? '',
            imageUrl: data['image-url'] ?? '',
            ingredientCount:
                (data['Cleaned-Ingredients'] as String?)?.split(',').length ??
                    0, // Count the number of ingredients
          );

          // Add to the loadedRecipes list
          loadedRecipes.add(recipe);
          print("Recipe parsed: ${recipe.ingredients}");
        } catch (e) {
          // Handle individual document parsing errors
          print("Error parsing document ${doc.id}: $e");
        }
      }

      // Debugging: Print the top 5 recipes
      print("Total loaded recipes: ${loadedRecipes.length}");

      // Update state with loaded recipes
      setState(() {
        recipes = loadedRecipes;
      });

      QuerySnapshot fsnapshot =
          await FirebaseFirestore.instance.collection('ingredients').get();

      // Extract the ingredient names into a list
      List<String> fridgeIngredients = fsnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      // Filter recipes based on fridge ingredients
      setState(() {
        availableRecipes =
            getDishesThatCanBeMade(loadedRecipes, fridgeIngredients);
        print(availableRecipes);
        isLoading = false;
      });
    } catch (e) {
      // Handle Firestore errors
      print("Error loading recipes from Firestore: $e");
    }

    // Return the list of loaded recipes
    return loadedRecipes;
  }

  // Function to filter recipes based on fridge ingredients
  List<Recipe> getDishesThatCanBeMade(
      List<Recipe> recipes, List<String> fridgeIngredients) {
    return recipes.where((recipe) {
      // Check if all ingredients in the recipe are in the fridge
      return recipe.ingredients
          .any((ingredient) => fridgeIngredients.contains(ingredient));
    }).toList();
  }

  Future<void> fetchFridgeIngredients() async {
    try {
      print("test");
      // Fetch data from Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('ingredients').get();

      // Extract the ingredient names into a list
      List<String> fridgeIngredients = snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      // Filter recipes based on fridge ingredients
      setState(() {
        availableRecipes = getDishesThatCanBeMade(recipes, fridgeIngredients);
        print(availableRecipes);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching fridge ingredients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure recipes are loaded
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 4.0,
          title: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: const Text(
              'PantryPal',
              style: TextStyle(
                fontFamily: 'DancingScript',
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Center(
            child:
                CircularProgressIndicator()), // Show loading spinner while data is loading
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 4.0,
        title: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: const Text(
            'PantryPal',
            style: TextStyle(
              fontFamily: 'DancingScript',
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                  child: Text(
                    'Hello!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Recipes Curated For You',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DancingScript'),
                ),
                // Display available recipes based on fridge ingredients
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns for recipes
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: availableRecipes.length,
                    itemBuilder: (context, index) {
                      Recipe recipe = availableRecipes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsPage(recipe: recipe.toMap()),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4.0,
                          child: Column(
                            children: [
                              Container(
                                height: 120, // Fixed height for the image
                                width: double.infinity,
                                child: Image.network(
                                  recipe.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Wrapping the text with Flexible to handle overflow
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Flexible(
                                  // Allow text to resize without overflowing
                                  child: Text(
                                    recipe.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow
                                        .ellipsis, // Handle text overflow
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
                // Trigger the chatbot action here (e.g., navigate to chatbot page)
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 60.0,
        child: BottomAppBar(
          color: Colors.teal,
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.fastfood, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MealPlanner()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.kitchen, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Fridge()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.restaurant, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecipeGenerator()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navigate back to the sign-in page
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}
