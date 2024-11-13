import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _SettingsState();
}

class _SettingsState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Student ni'),
    );
  }
}
