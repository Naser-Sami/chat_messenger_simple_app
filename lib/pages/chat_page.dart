import 'package:chat_messenger_app/components/chat_bubble.dart';
import 'package:chat_messenger_app/components/custom_text_field.dart';
import 'package:chat_messenger_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there's something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);

      // clear the controller after sending a message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.receiverUserEmail),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // .. message
            Expanded(child: _buildMessageList()),

            // .. user input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // .. build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unexpected error"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // .. build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align the messages to the right if the sender is the current user, otherwise to the left
    AlignmentGeometry? alignment =
        (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Text(
              data['senderEmail'],
            ),
            const SizedBox(
              height: 10.0,
            ),
            ChatBubble(
              message: data['message'],
              senderIsCurrentUser:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid),
            ),
          ],
        ),
      ),
    );
  }

  // .. build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        // . text field
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
                controller: _messageController,
                hintText: "Enter message",
                obscureText: false),
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(
            Icons.arrow_upward,
            size: 25,
          ),
        ),
      ],
    );
  }
}
