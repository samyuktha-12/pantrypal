import 'package:flutter/material.dart';

class MealPlanner extends StatelessWidget {
  const MealPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner', style: TextStyle(fontFamily: 'DancingScript', fontSize: 38.0)),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          'Welcome to Meal Planner!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
