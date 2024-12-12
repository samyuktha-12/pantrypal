import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To pick images from gallery or camera
import 'package:firebase_vertexai/firebase_vertexai.dart'; // For using Gemini API
import 'dart:io'; // For file handling

class RecipeGenerator extends StatefulWidget {
  const RecipeGenerator({super.key});

  @override
  _RecipeGeneratorState createState() => _RecipeGeneratorState();
}

class _RecipeGeneratorState extends State<RecipeGenerator> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _response = ''; // To hold recipe response

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Function to trigger chat and get recipe using Gemini API
  Future<void> _getRecipeFromImage() async {
    if (_image == null) return;

    try {
      final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash-exp');
      final chat = model.startChat();

      // Provide a text prompt to include with the image
      final prompt = Content.text("I have a dish from the image uploaded. Please provide the recipe for this dish.");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Generator',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 38.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Intro text
            Text(
              'Welcome to the Recipe Generator! Upload an image of a dish, and we will provide the recipe for you.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Center the button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Pick Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // If image is selected, show it and the "Get Recipe" button
            if (_image != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_image!.path),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _getRecipeFromImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Get Recipe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),
            // Show recipe if available
            if (_response.isNotEmpty) ...[
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipe Instructions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _response,
                        style: const TextStyle(
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
