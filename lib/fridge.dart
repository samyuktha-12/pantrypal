import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_vertexai/firebase_vertexai.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Import the AI API

class Fridge extends StatefulWidget {
  const Fridge({super.key});

  @override
  _FridgeState createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  final ImagePicker _picker = ImagePicker();
  String _response = '';
  XFile? _image;

  // Function to fetch ingredients from Firestore
  Stream<List<Ingredient>> getIngredients() {
    return FirebaseFirestore.instance
        .collection('ingredients')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient(
                  name: doc['name'],
                  quantity: doc['quantity'],
                  date: doc['date'],
                  id: doc.id,
                ))
            .toList());
  }

Future<void> processAndAddIngredientsToFirebase(String responseText) async {
  try {
    // Step 1: Parse the responseText into a list of ingredients
    List<Map<String, dynamic>> ingredients =
        _extractIngredientsFromText(responseText);

    // Step 2: Add each ingredient to Firebase
    for (var ingredient in ingredients) {
      await FirebaseFirestore.instance.collection('ingredients').add({
        'name': ingredient['name'],
        'quantity': ingredient['quantity'],
        'date': ingredient['date'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    print("Ingredients successfully added to Firebase.");
  } catch (e) {
    print("Error processing or adding ingredients to Firebase: $e");
  }
}

Future<void> addToFirebaseFromSpeech(String responseText) async {
  try {
    // Step 1: Extract the quantity and ingredient from the speech response
    print(responseText);
    RegExp regExp = RegExp(r'add (\d+\.?\d*\s?\w*)\s*of\s*([a-zA-Z\s]+)', caseSensitive: false);

    Match? match = regExp.firstMatch(responseText);

    if (match != null) {
      String quantity = match.group(1)!;
      String ingredient = match.group(2)!.trim();

      // Step 2: Get the current date
      String currentDate = DateTime.now().toString().split(' ')[0];

      // Step 3: Add the data to Firebase
      await FirebaseFirestore.instance.collection('ingredients').add({
        'name': ingredient,
        'quantity': quantity,
        'date': currentDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Ingredient added to Firebase: $ingredient, Quantity: $quantity");
    } else {
      print("Could not match the expected format: 'add <quantity> of <ingredient>'");
    }
  } catch (e) {
    print("Error adding ingredient to Firebase: $e");
  }
}


// Helper function to parse raw text into a list of ingredient maps
List<Map<String, dynamic>> _extractIngredientsFromText(String responseText) {
  List<Map<String, dynamic>> ingredients = [];

  // Split the responseText into lines
  List<String> lines = responseText.split('\n');

  // Loop through each line to extract ingredient details
  for (var line in lines) {
    line = line.trim();
    if (line.isNotEmpty) {
      try {
        // Split the line into components and clean up the text
        List<String> parts = line.split(',');
        String name = parts[0].split(':').last.trim().replaceAll("'", "");
        String quantity = parts[1].split(':').last.trim().replaceAll("'", "");
        String date = parts[2].split(':').last.trim().replaceAll("'", "");

        // Add the parsed ingredient to the list
        ingredients.add({
          'name': name,
          'quantity': quantity,
          'date': date,
        });
      } catch (e) {
        print("Error parsing line: $line, Error: $e");
      }
    }
  }

  return ingredients;
}


  // Function to delete an ingredient
  Future<void> _deleteIngredient(String id) async {
    await FirebaseFirestore.instance.collection('ingredients').doc(id).delete();
  }

  // Function to edit an ingredient
  Future<void> _editIngredient(
      BuildContext context, id, String quantity, String date) async {
    final TextEditingController _quantityController =
        TextEditingController(text: quantity);
    final TextEditingController _dateController =
        TextEditingController(text: date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date of Buying',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () async {
                final String newQuantity = _quantityController.text;
                final String newDate = _dateController.text;

                if (newQuantity.isNotEmpty && newDate.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('ingredients')
                      .doc(id)
                      .update({
                    'quantity': newQuantity,
                    'date': newDate,
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  Future<void> addIngredientsThroughSpeech() async {
  TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  String _transcribedText = '';

  // Initialize speech-to-text
  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("Speech recognition is not available.");
    }
  }

  // Start listening
  void _startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.hasConfidenceRating && result.confidence > 0.1) {
          _transcribedText = result.recognizedWords;
          _textController.text = _transcribedText;
        }
      },
      listenFor: Duration(minutes: 1),
    );
    _isListening = true;
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    _isListening = false;
  }

  // Extract ingredients from text
  List<Map<String, dynamic>> _extractIngredientsFromText(String text) {
    List<Map<String, dynamic>> ingredients = [];
    RegExp regex = RegExp(r'add (\d+ \w+) of (\w+)');
    var matches = regex.allMatches(text);

    for (var match in matches) {
      ingredients.add({
        'quantity': match.group(1),
        'name': match.group(2),
        'date': DateTime.now().toIso8601String(),
      });
    }

    return ingredients;
  }

  // Show dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add Ingredients'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Your transcription will appear here...',
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                  onPressed: () {
                    setState(() {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await addToFirebaseFromSpeech(
                      _textController.text);
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );

  // Initialize speech-to-text when the dialog is shown
  _initializeSpeech();
}


  // Function to show Add Ingredient Dialog
  Future<void> _showAddIngredientDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient Name',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                  ),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Buying (YYYY-MM-DD)',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text;
                final String quantity = quantityController.text;
                final String date = dateController.text;

                if (name.isNotEmpty && quantity.isNotEmpty && date.isNotEmpty) {
                  await _addIngredientToFirebase(name, quantity, date);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  // Function to add ingredient to Firebase
  Future<void> _addIngredientToFirebase(
      String name, String quantity, String date) async {
    try {
      await FirebaseFirestore.instance.collection('ingredients').add({
        'name': name,
        'quantity': quantity,
        'date': date,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding ingredient to Firebase: $e');
    }
  }

  // Function to extract ingredients from image
  Future<void> _getRecipeFromImage() async {
    if (_image == null) return;

    try {
      final model = FirebaseVertexAI.instance
          .generativeModel(model: 'gemini-2.0-flash-exp');
      final chat = model.startChat();

      // Provide a text prompt to include with the image
      final prompt = Content.text(
          "I have an image of a bill for groceries. Please extract only the food ingredients and their quantities. If any quantity is not mentioned, assume 100g. For each ingredient, return the details in the following format:\nIngredient 1: 'ingredient_name', Quantity: quantity, Date: 'current_date'.\"\nThis format should ensure that the information extracted is neatly presented and easy to process.");

      // Read image bytes
      final imageBytes = await File(_image!.path).readAsBytes();
      final imagePart = Content.inlineData('image/jpeg', imageBytes);

      // To stream generated text output, call generateContentStream with the text and image
      final response = await model.generateContentStream([
        prompt, // Content.text already returns a Content object
        imagePart // Content.inlineData already returns a Content object
      ]);

      await for (final chunk in response) {
        if (chunk.text != null) {
          setState(() {
            _response += chunk.text!;
            _response = _response
                .replaceAll('###', '')
                .replaceAll('**', '')
                .replaceAll('##', '')
                .replaceAll('*', '•');
          });
        }
      }
    } catch (e) {
      print("Error processing the image: $e");
    }
  }

  // Function to show scan dialog and upload image
  Future<void> _scanImage() async {
    // Pick an image from camera or gallery
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });

      // Process the image to get the recipe
      await _getRecipeFromImage();
      print(Text(_response));

      // Show dialog to confirm the ingredients
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Ingredients'),
            content: Text(_response), // Display extracted ingredients here
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // You can add the ingredients to Firebase here after confirmation
                  final currentDate = DateTime.now().toIso8601String();
                  //await _addIngredientToFirebase(
                      //"Extracted Ingredient", "100g", currentDate);
                    await processAndAddIngredientsToFirebase(_response);
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge',
            style: TextStyle(fontFamily: 'DancingScript', fontSize: 38.0)),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Ingredient>>(
        stream: getIngredients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No ingredients found.'));
          }

          final ingredients = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                'Quantity: ${ingredient.quantity}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Date: ${ingredient.date}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _editIngredient(
                                  context,
                                  ingredient.id,
                                  ingredient.quantity,
                                  ingredient.date),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteIngredient(ingredient.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddIngredientDialog(context),
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _scanImage,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: addIngredientsThroughSpeech,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.mic),
          ),
        ],
      ),
      
    );
  }
}

// Ingredient model class
class Ingredient {
  final String id;
  final String name;
  final String quantity;
  final String date;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.date,
  });
}
