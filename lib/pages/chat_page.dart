import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/model/messages.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userId;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // each message will be an instance of Message class saved in firestore
      await _chatService.sendMessage(message, widget.groupId);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade800,
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.userId, widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => _buildMessageItem(
                snapshot.data!.docs[index],
                MediaQuery.of(context).size.width * 0.5),
          );
        }
      },
    );
  }
}

// this build the individual messages.
Widget _buildMessageItem(DocumentSnapshot document, double width) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  var alignment = (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;
  final Color senderColor = getColorForSender(data['senderId']);

  return Container(
    padding: const EdgeInsets.all(8),
    width: width,
    alignment: alignment,
    child: Column(
      crossAxisAlignment:
          (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // color: (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
            //     ? Colors.blue.shade800
            //     : Colors.orange.shade800,
            color: senderColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            data['message'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          data['senderEmail'],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

Map<String, Color> senderColorMap = {}; // To store sender colors

Color getColorForSender(String senderId) {
  if (!senderColorMap.containsKey(senderId)) {
    senderColorMap[senderId] = getRandomColor();
  }

  return senderColorMap[senderId]!;
}
