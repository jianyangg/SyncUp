import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_up/model/messages.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String message, String groupId) async {
    // get current user
    final currUser = _firebaseAuth.currentUser;
    final currUserId = currUser!.uid;
    // final userRef = _firestore.collection('users').doc(userId);
    // final chatRef = userRef.collection('chats').doc(chatId);
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currUserId,
      senderEmail: currUser.email!,
      groupId: groupId,
      message: message,
      timestamp: timestamp,
    );

    // chatRoomId will be groupId;
    String chatRoomId = groupId;

    // add message to firestore
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userId, String groupId) {
    String chatRoomId = groupId;
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
