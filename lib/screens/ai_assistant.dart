import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class AiAssistant extends StatefulWidget {
  const AiAssistant({super.key});

  @override
  State<AiAssistant> createState() => _AiAssistantState();
}

class _AiAssistantState extends State<AiAssistant> {
  final model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-3-flash-preview');

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
