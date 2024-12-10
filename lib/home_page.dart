import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Example color
        elevation: 4.0, // Mild shadow
        title: Padding(
          padding:
              const EdgeInsets.only(top: 3.0), // Adjust the padding as needed
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
      body: Center(
        child: Text(
          'Hello, $userName!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60.0,
        child: BottomAppBar(
          color: Colors.teal, // Background color of BottomAppBar
          elevation: 8.0, // Mild shadow
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.fastfood,
                      color: Colors.white), // Food icon
                  onPressed: () {
                    // Food icon action
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.home, color: Colors.white), // Home icon
                  onPressed: () {
                    // Home icon action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.kitchen,
                      color: Colors.white), // Fridge icon
                  onPressed: () {
                    // Fridge icon action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
