import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String id;
  const MessageScreen({super.key, required this.id});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Text('Message Screen'),
      ),
    );
  }
}
