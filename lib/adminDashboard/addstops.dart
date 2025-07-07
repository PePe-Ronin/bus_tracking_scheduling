import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Addstops extends StatefulWidget {
  const Addstops({super.key});

  @override
  State<Addstops> createState() => _AddstopsState();
}

class _AddstopsState extends State<Addstops> {
  final TextEditingController stopID = TextEditingController();
  final TextEditingController latlng = TextEditingController();
  final TextEditingController routeID = TextEditingController();
  final TextEditingController status = TextEditingController();
  final String password = "stiibus2024";
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Bus Stops',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter Bus Stops below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              _buildTextField('Enter Stop Name', stopID),
              _buildTextField('Select Stop Location', latlng),
              _buildTextField('Select Route', routeID),
              _buildTextField('Set Status', status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
