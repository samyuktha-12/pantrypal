import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (await Permission.microphone.request().isGranted) {
      _initSpeech();
    }
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
    if (available) {
      setState(() {
        _isListening = false;
      });
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  void _startListening() {
    _text = ''; // Clear the text before starting to listen
    _textController.clear();
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
          _textController.text = _text;
        });
      },
      listenFor: Duration(minutes: 1),
      localeId: 'en_US',
      onSoundLevelChange: (level) => print('Sound level: $level'),
      cancelOnError: true,
      partialResults: true,
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Recognized text will appear here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}