import 'package:flutter/material.dart';
import 'package:note_app_sample/screens/screen_all_notes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: ScreenAllNotes(),
    );
  }
}
