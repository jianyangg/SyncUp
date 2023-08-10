import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String groupId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.groupId,
    required this.message,
    required this.timestamp,
  });

  // convert message to a map to be stored.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'groupId': groupId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
