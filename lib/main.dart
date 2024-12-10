import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'google_sign_in.dart';  // The file where Google Sign-In logic is handled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Demo',
      theme: ThemeData.dark(),
      home: const GoogleSignInPage(),  // Starts with GoogleSignInPage
    );
  }
}

