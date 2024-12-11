import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'meal_planner.dart';
import 'fridge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_details_page.dart';

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
    fetchFridgeIngredients(); // Load recipes on widget initialization
  }

  // Function to load recipes from CSV
  List<Recipe> loadRecipes() {
    List<Recipe> loadedRecipes = [
      Recipe(
        name: "Vegetable Curry",
        ingredients: ["onion", "coriander powder", "turmeric powder"],
        totalTimeInMins: 30,
        cuisine: "Indian",
        instructions:
            "Chop the vegetables, fry the spices, add water, and cook until done.",
        url: "https://example.com/veg_curry",
        imageUrl:
            "https://images.immediate.co.uk/production/volatile/sites/30/2022/06/Courgette-curry-c295fa0.jpg?quality=90&webp=true&resize=600,545",
        ingredientCount: 7,
      ),
      Recipe(
        name: "Chickpea Salad",
        ingredients: [
          "chickpeas",
          "tomato",
          "cucumber",
          "olive oil",
          "lemon",
          "coriander"
        ],
        totalTimeInMins: 15,
        cuisine: "Mediterranean",
        instructions:
            "Mix all ingredients together in a bowl and toss with olive oil and lemon juice.",
        url: "https://example.com/chickpea_salad",
        imageUrl: "https://example.com/chickpea_salad_image.jpg",
        ingredientCount: 6,
      ),
      Recipe(
        name: "Spaghetti Aglio e Olio",
        ingredients: [
          "spaghetti",
          "garlic",
          "olive oil",
          "red pepper flakes",
          "parsley"
        ],
        totalTimeInMins: 20,
        cuisine: "Italian",
        instructions:
            "Boil spaghetti, then sauté garlic in olive oil with red pepper flakes. Mix with spaghetti.",
        url: "https://example.com/spaghetti_aglio_olio",
        imageUrl: "https://example.com/spaghetti_aglio_olio_image.jpg",
        ingredientCount: 5,
      ),
      Recipe(
        name: "Tomato Soup",
        ingredients: [
          "tomatoes",
          "garlic",
          "onion",
          "vegetable broth",
          "olive oil"
        ],
        totalTimeInMins: 25,
        cuisine: "American",
        instructions:
            "Sauté onions and garlic, add tomatoes and broth, then blend until smooth.",
        url: "https://example.com/tomato_soup",
        imageUrl: "https://example.com/tomato_soup_image.jpg",
        ingredientCount: 5,
      ),
      Recipe(
        name: "Fruit Salad",
        ingredients: ["apple", "banana", "orange", "grapes", "honey"],
        totalTimeInMins: 10,
        cuisine: "American",
        instructions:
            "Chop the fruits and mix together. Drizzle with honey for extra flavor.",
        url: "https://example.com/fruit_salad",
        imageUrl: "https://example.com/fruit_salad_image.jpg",
        ingredientCount: 5,
      ),
    ];

    // Update the state with loaded recipes
    setState(() {
      recipes = loadedRecipes;
    });

    return loadedRecipes;
  }

  // Function to filter recipes based on fridge ingredients
  List<Recipe> getDishesThatCanBeMade(
      List<Recipe> recipes, List<String> fridgeIngredients) {
    return recipes.where((recipe) {
      // Check if all ingredients in the recipe are in the fridge
      return recipe.ingredients
          .every((ingredient) => fridgeIngredients.contains(ingredient));
    }).toList();
  }

  Future<void> fetchFridgeIngredients() async {
    try {
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
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10.0),
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
              padding: const EdgeInsets.only(left: 16.0),
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
              'Recipes You Can Make:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          Image.network(
                            recipe.imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
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
