import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Addstops extends StatefulWidget {
  const Addstops({super.key});

  @override
  State<Addstops> createState() => _AddstopsState();
}

class _AddstopsState extends State<Addstops> {
  final TextEditingController stopID = TextEditingController();
  final TextEditingController latitude = TextEditingController();
  final TextEditingController longitude = TextEditingController();
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Bus Stops',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enter Bus Stops below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              _buildTextField('Enter Schedule ID', stopID),
              _buildTextField('Select Route Name', latitude),
              _buildTextField('Select Departure Time', longitude),
              _buildTextField('Select Arrival Time', routeID),
              _buildTextField('Select Bus Number', status),
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
