import 'package:flutter/material.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _SettingsState();
}

class _SettingsState extends State<ParentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Parents ni'),
    );
  }
}
