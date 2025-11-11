import 'app_user.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType; // text, image, document
  final DateTime sentAt;
  final bool isRead;
  
  // Optional user objects
  final AppUser? sender;
  final AppUser? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.sentAt,
    required this.isRead,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      messageType: json['message_type'],
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
