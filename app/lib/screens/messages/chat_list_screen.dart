import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  final List<Map<String, dynamic>> _chats = const [
    {
      'id': '1',
      'name': 'Dr. Enoch',
      'specialty': 'Cardiologist',
      'lastMessage': 'Hello, how are you feeling today?',
      'time': '10:30 AM',
      'unread': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Dr. seabata',
      'specialty': 'Neurologist',
      'lastMessage': 'Your test results are ready',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
    },
    {
      'id': '3',
      'name': 'Medical lebabo',
      'specialty': 'Support',
      'lastMessage': 'Your appointment is confirmed',
      'time': 'Mar 12',
      'unread': 0,
      'isOnline': true,
    },
    {
      'id': '4',
      'name': 'Dr. kush',
      'specialty': 'Dermatologist',
      'lastMessage': 'Please send photos of the affected area',
      'time': 'Mar 10',
      'unread': 1,
      'isOnline': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.medical_services, 'Doctors', Colors.blue),
                _buildQuickAction(Icons.support_agent, 'Support', Colors.green),
                _buildQuickAction(Icons.emergency, 'Emergency', Colors.red),
                _buildQuickAction(Icons.group, 'Group Chat', Colors.purple),
              ],
            ),
          ),
          
          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return _buildChatItem(context, chat);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat
          _showNewChatDialog(context);
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              color: Colors.blue.shade700,
            ),
          ),
          if (chat['isOnline'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(
            chat['name'],
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: chat['unread'] > 0 ? Colors.black : Colors.grey.shade700,
            ),
          ),
          if (chat['specialty'] != 'Support')
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                chat['specialty'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        chat['lastMessage'],
        style: TextStyle(
          color: chat['unread'] > 0 ? Colors.black : Colors.grey.shade600,
          fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          if (chat['unread'] > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => context.go('/chat/${chat['id']}'),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.blue),
              title: const Text('Chat with Doctor'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to doctors list
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: const Text('Customer Support'),
              onTap: () {
                Navigator.pop(context);
                context.go('/chat/support');
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: const Text('Emergency Services'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement emergency chat
              },
            ),
          ],
        ),
      ),
    );
  }
}
