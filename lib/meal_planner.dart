import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _dietType = 'Vegetarian';
  String _foodPreference = 'Veg';
  String _cuisine = 'Indian';
  String _response = ''; // To hold chatbot response
  final List<String> _dietOptions = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
  final List<String> _foodPreferences = ['Veg', 'Non-Veg'];
  final List<String> _cuisineOptions = [
    'Indian',
    'Italian',
    'Chinese',
    'Mexican'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Firebase here
    _initializeFirebase();
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey:
            'AIzaSyDmEJSYrJLzFi9xPXreSPbfUsT01UooZLA', // Replace with your API key
        appId:
            '1:153285459861:android:cd58f04eb5bddeac19009c', // Replace with your App ID
        messagingSenderId: '153285459861', // Replace with your Sender ID
        projectId: 'pantrypal-d1c01', // Replace with your Project ID
      ),
    );
  }

  // Function to trigger chat and get a response from Vertex AI
  Future<void> _getChatResponse() async {
    final model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
    final chat = model.startChat();

    final prompt =
        Content.text('I need a meal plan for ${_daysController.text} days, '
            'with a daily calorie intake of ${_caloriesController.text} kcal, '
            'and I prefer a ${_dietType} diet with ${_foodPreference} food, '
            'cuisine being ${_cuisine}.');

    final response = await chat
        .sendMessageStream(prompt); // Directly passing the Content object

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
  }

  Future<void> _generatePdf(String response) async {
  // If the response is empty, set it to "Empty"
  if (response.isEmpty) {
    response = 'Empty'; // Set response to "Empty" if no meal plan is available
  }

  // Debugging message to verify the content
  print("Response to be rendered in PDF: $response");

  // Load custom font
  final ttf = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');

  // Split the response by newline and filter out empty or whitespace-only lines
  List<String> lines = response
      .split('\n')
      .where((line) => line.trim().isNotEmpty) // Remove empty lines or lines with only spaces
      .toList();

  // Handle any unexpected formatting in the response text
  lines = lines.map((line) {
    line = line.trim(); // Remove leading and trailing spaces
    return line;
  }).toList();

  final pdf = pw.Document();
  
  // Define the maximum number of lines per page
  const int maxLinesPerPage = 20;  // Adjust this based on your font size and layout
  int currentLineIndex = 0;

  while (currentLineIndex < lines.length) {
    final linesOnCurrentPage = lines.sublist(currentLineIndex, 
        currentLineIndex + maxLinesPerPage <= lines.length
            ? currentLineIndex + maxLinesPerPage
            : lines.length);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                  'Meal Plan',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: pw.Font.ttf(ttf), 
                    // Apply custom bold font
                  ),
                )),
                pw.SizedBox(height: 10),
                // Render each line separately
                ...linesOnCurrentPage.map((line) => pw.Text(
                      line,
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: pw.Font.ttf(ttf), // Apply custom regular font
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );

    // Update the current line index to the next set of lines
    currentLineIndex += maxLinesPerPage;
  }

  // Debugging message to confirm that the PDF is generated and ready for download
  print('PDF generated successfully, starting download...');

  // Save the PDF and trigger the download
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(fontFamily: 'DancingScript', fontSize: 38.0),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        // Wrap the entire body in a scrollable widget
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white), // White text color
                decoration: InputDecoration(
                  labelText: 'Number of Days',
                  labelStyle:
                      const TextStyle(color: Colors.white), // White label
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // White focus border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // White border when enabled
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of days.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white), // White text color
                decoration: InputDecoration(
                  labelText: 'Calorie Requirement (kcal/day)',
                  labelStyle:
                      const TextStyle(color: Colors.white), // White label
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // White border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // White focus border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // White border when enabled
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your calorie requirement.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _dietType,
                decoration: const InputDecoration(
                  labelText: 'Diet Type',
                  labelStyle: TextStyle(color: Colors.white), // White label
                  border: OutlineInputBorder(),
                ),
                items: _dietOptions.map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dietType = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _foodPreference,
                decoration: const InputDecoration(
                  labelText: 'Food Preference',
                  labelStyle: TextStyle(color: Colors.white), // White label
                  border: OutlineInputBorder(),
                ),
                items: _foodPreferences.map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _foodPreference = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _cuisine,
                decoration: const InputDecoration(
                  labelText: 'Cuisine',
                  labelStyle: TextStyle(color: Colors.white), // White label
                  border: OutlineInputBorder(),
                ),
                items: _cuisineOptions.map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cuisine = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _getChatResponse();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal, // Text color
                ),
                child: const Text('Generate Meal Plan'),
              ),
              const SizedBox(height: 20.0),
              if (_response.isNotEmpty) ...[
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Meal Plan:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _response,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _generatePdf(
                        _response); // Generate PDF and trigger download
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal, // Text color
                  ),
                  child: const Text('Download Meal Plan as PDF'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
