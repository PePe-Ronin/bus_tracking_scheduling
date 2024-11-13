import 'package:flutter/material.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _SettingsState();
}

class _SettingsState extends State<DriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Driver ni'),
    );
  }
}
