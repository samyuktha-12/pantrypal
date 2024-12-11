import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Fridge extends StatelessWidget {
  const Fridge({super.key});

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

  // Function to delete an ingredient
  Future<void> _deleteIngredient(String id) async {
    await FirebaseFirestore.instance.collection('ingredients').doc(id).delete();
  }

  // Function to edit an ingredient
  Future<void> _editIngredient(BuildContext context, id, String quantity, String date) async {
    final TextEditingController _quantityController = TextEditingController(text: quantity);
    final TextEditingController _dateController = TextEditingController(text: date);

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
                  await FirebaseFirestore.instance.collection('ingredients').doc(id).update({
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
  Future<void> _addIngredientToFirebase(String name, String quantity, String date) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge', style: TextStyle(fontFamily: 'DancingScript', fontSize: 38.0)),
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
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Quantity: ${ingredient.quantity}'),
                        Text('Date: ${ingredient.date}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _editIngredient(context, ingredient.id, ingredient.quantity, ingredient.date),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIngredientDialog(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
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
