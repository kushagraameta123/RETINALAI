import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  
  const ChatScreen({super.key, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello! How can I help you today?',
      'isMe': false,
      'time': '10:25 AM',
    },
    {
      'id': '2',
      'text': 'Hi Doctor, I\'ve been experiencing headaches for the past few days.',
      'isMe': true,
      'time': '10:26 AM',
    },
    {
      'id': '3',
      'text': 'I see. Can you describe the pain? Is it sharp or dull?',
      'isMe': false,
      'time': '10:27 AM',
    },
    {
      'id': '4',
      'text': 'It\'s a dull, constant pain behind my eyes.',
      'isMe': true,
      'time': '10:28 AM',
    },
    {
      'id': '5',
      'text': 'Have you taken any medication for it?',
      'isMe': false,
      'time': '10:29 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr. Sarah Johnson',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('View Profile')),
              const PopupMenuItem(child: Text('Medical History')),
              const PopupMenuItem(child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.blue.shade700),
                  onPressed: () {
                    _showAttachmentOptions();
                  },
                ),
                
                // Message input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    maxLines: null,
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue.shade700),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendMessage(_messageController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 16, color: Colors.blue.shade700),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade700 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add({
        'id': (_messages.length + 1).toString(),
        'text': text,
        'isMe': true,
        'time': 'Now',
      });
    });
    _messageController.clear();
    
    // Simulate reply after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'id': (_messages.length + 1).toString(),
          'text': 'Thank you for sharing. I recommend scheduling an appointment for further evaluation.',
          'isMe': false,
          'time': 'Now',
        });
      });
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Medical Document'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement document picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.blue),
              title: const Text('Lab Results'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement lab results
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
