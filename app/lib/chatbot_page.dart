import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Import for API calls

// --- API Key (Replace with your actual key) ---
const String GEMINI_API_KEY = "AIzaSyAmHJlHgnAo0m9fUNf_xUSOFFJby8SuiNU"; // <-- YOUR KEY IS NOW HERE!

// --- Color and Style Definitions ---
const Color primaryBlue = Color.fromARGB(255, 85, 154, 233);
const Color accentGreen = Color(0xFF38A169);

// Define the structure of a message
class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

// Simple Chatbot logic (Placeholder for AI connection)
class ChatBotProvider extends ChangeNotifier {
  // System Instruction to constrain the AI's behavior and domain knowledge.
  static const String systemInstruction = 
      "You are a sophisticated AI Vision Assistant specializing exclusively in ophthalmology, specifically focused on **retinal diseases, diagnosis, and the use of deep learning models** in medical image analysis. Be professional, clever, and medically accurate. If a user asks a question unrelated to retinal disease, general eye health, or deep learning diagnosis (e.g., 'What is the weather?' or 'What is a car?'), you **must** politely decline, stating your specialization. Always prioritize providing accurate, high-quality, evidence-based information related to your domain.";

  final List<Message> _messages = [
    Message(
      text: "Welcome to the **Retinal-AI Vision Assistant**. I am powered by Gemini and specialized in deep learning diagnosis for retinal health. How can I help you today?", 
      isUser: false
    )
  ];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  final List<String> examplePrompts = [
    "How does deep learning detect diabetic retinopathy?",
    "Explain the symptoms of Age-related Macular Degeneration (AMD).",
    // "What are Drusen and why are they important in diagnosis?",
    // "What is Glaucoma and how is it related to the retina?"
  ];

  Future<void> handleSend(String promptText) async {
    if (promptText.trim().isEmpty || _isLoading) return;

    // 1. Add user message
    final userMessage = Message(text: promptText, isUser: true);
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Check for API key presence (now redundant, but good practice)
      if (GEMINI_API_KEY.isEmpty) {
        throw Exception('GEMINI_API_KEY is missing. Please add your key.');
      }
      
      // 2. Prepare the Gemini API Payload
      const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=$GEMINI_API_KEY';

      final payload = {
        'contents': [
          {'parts': [{'text': promptText}]}
        ],
        'systemInstruction': {
          'parts': [{'text': systemInstruction}]
        },
        // Enable Google Search grounding for up-to-date medical knowledge
        'tools': [
          {"google_search": {}}
        ],
      };

      // 3. Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode != 200) {
        // Log detailed error for debugging
        debugPrint('API Error Details: ${response.body}');
        throw Exception('API failed with status ${response.statusCode}. Please check console for details.');
      }

      final jsonResponse = json.decode(response.body);
      final generatedText = jsonResponse['candidates']?[0]['content']?['parts']?[0]['text'] ?? 
                            'Error: Could not retrieve response text.';

      // 4. Add AI message
      final aiMessage = Message(text: generatedText, isUser: false);
      _messages.add(aiMessage); 

    } catch (e) {
      debugPrint('Gemini API Error: $e');
      _messages.add(Message(text: 'I am currently unable to connect to the diagnostic AI engine. Please check your internet connection and ensure the API key is valid.', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatBotProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Vision Assistant'),
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          elevation: 1,
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const Column(
                children: [
                  Expanded(child: MessageList()),
                  ChatInputArea(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatBot = Provider.of<ChatBotProvider>(context);
    
    // Automatically scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Scrollable.maybeOf(context) != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 1.0,
        );
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: chatBot.messages.length + (chatBot.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < chatBot.messages.length) {
          final msg = chatBot.messages[index];
          return MessageBubble(message: msg);
        } else {
          // Loading Indicator
          return const BotLoadingIndicator();
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Icon (Left)
          if (!isUser) 
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8.0, top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)], // blue-500 to indigo-600
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
            ),
          
          // Message Content
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser ? primaryBlue.withOpacity(0.1) : primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 24 : 8),
                  topRight: Radius.circular(isUser ? 8 : 24),
                  bottomLeft: const Radius.circular(24),
                  bottomRight: const Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: TextStyle(color: isUser ? primaryBlue : Colors.white, fontSize: 16),
                  strong: TextStyle(color: isUser ? primaryBlue : Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // User Icon (Right)
          if (isUser) 
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 8.0, top: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFF4A5568), size: 20),
            ),
        ],
      ),
    );
  }
}

class BotLoadingIndicator extends StatelessWidget {
  const BotLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Icon
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8.0, top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
          ),
          // Loading Bubble
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vision is thinking', style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(width: 8),
                SizedBox(
                  width: 10,
                  height: 5,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryBlue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChatInputArea extends StatefulWidget {
  const ChatInputArea({super.key});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatBot = Provider.of<ChatBotProvider>(context);
    final isLoading = chatBot.isLoading;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Example Prompts
          Wrap(
            spacing: 1.0,
            runSpacing: 1.0,
            children: chatBot.examplePrompts.map((prompt) {
              return ActionChip(
                label: Text(prompt, style: TextStyle(color: isLoading ? Colors.grey : primaryBlue)),
                backgroundColor: Colors.grey.shade50,
                side: BorderSide(color: isLoading ? Colors.grey.shade300 : primaryBlue.withOpacity(0.5)),
                onPressed: isLoading ? null : () {
                  // Send prompt directly without prefilling the input field (for clean UI)
                  chatBot.handleSend(prompt);
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Input Field and Send Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask about a retinal condition...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  ),
                  onSubmitted: isLoading ? null : (value) {
                    if (value.trim().isNotEmpty) {
                      chatBot.handleSend(value);
                      _controller.clear();
                    }
                  },
                  enabled: !isLoading,
                ),
              ),
              const SizedBox(width: 8.0),
              SizedBox(
                width: 48,
                height: 48,
                child: FloatingActionButton(
                  heroTag: 'sendBtn',
                  onPressed: isLoading || _controller.text.trim().isEmpty ? null : () {
                    chatBot.handleSend(_controller.text);
                    _controller.clear();
                  },
                  backgroundColor: isLoading || _controller.text.trim().isEmpty
                      ? Colors.grey
                      : primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                  child: const Icon(Icons.send, color: Colors.white, size: 15),
                ),
              ),
            ],
          ),

          // Disclaimer
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Medical Disclaimer: This AI assistant is for informational purposes only and is not a substitute for professional medical advice.',
                    style: TextStyle(color: Colors.amber.shade800, fontSize: 8),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
