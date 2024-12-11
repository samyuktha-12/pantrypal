import 'package:flutter/material.dart';
import 'chatbot_client.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatController = TextEditingController();
  final _chatClient = ChatbotClient(
    projectId: 'pantrypal-444310',
    agentId: 'b516e3c2-ad9d-4cf4-8d25-9630bf824a81',
    location: 'global',
  );

  List<String> _messages = [];

  void _sendMessage() async {
    final message = _chatController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
    });

    final response = await _chatClient.sendMessage('1', message);
    print(response);
    setState(() {
      _messages.add('Bot: $response');
    });

    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PantryPal Bot',
          style: TextStyle(fontFamily: 'DancingScript', fontSize: 34.0),
        ),
        backgroundColor: Colors.teal, // Set app bar color to teal
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUserMessage = message.startsWith('You:');

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight // User message on the right
                        : Alignment.centerLeft, // Bot message on the left
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.white : Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: isUserMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUserMessage
                                ? 'You'
                                : 'Bot', // Display You/ Bot above message
                            style: TextStyle(
                              color: isUserMessage ? Colors.teal : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isUserMessage) // Show bot image for bot messages
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right:
                                          8.0), // Small space between image and text
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/logo.png'),
                                    radius: 15,
                                  ),
                                ),
                              SizedBox(
                                  width: 10), // Space between image and text
                              Flexible(
                                child: Text(
                                  message
                                      .substring(message.indexOf(':') + 1)
                                      .trim(),
                                  style: TextStyle(
                                    color: isUserMessage
                                        ? Colors.teal
                                        : Colors.white,
                                    fontSize: 16,
                                  ),
                                  softWrap: true, // Allow wrapping of text
                                  overflow:
                                      TextOverflow.visible, // No truncation
                                ),
                              ),
                              if (isUserMessage) // Show user image for user messages
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left:
                                          8.0), // Small space between image and text
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/logo.png'),
                                    radius: 15,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(
                        color: Colors.white), // Set text color to white
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle:
                          TextStyle(color: Colors.white), // White hint text
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.white), // Default border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.black), // Black border on focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.black), // Black border when enabled
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
