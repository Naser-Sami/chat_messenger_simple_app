import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool senderIsCurrentUser;
  const ChatBubble(
      {super.key, required this.message, required this.senderIsCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: senderIsCurrentUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
