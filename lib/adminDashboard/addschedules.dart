import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Addschedules extends StatefulWidget {
  const Addschedules({super.key});

  @override
  State<Addschedules> createState() => _AddschedulesState();
}

class _AddschedulesState extends State<Addschedules> {
  final TextEditingController schedID = TextEditingController();
  final TextEditingController routeID = TextEditingController();
  final TextEditingController departureTime = TextEditingController();
  final TextEditingController arrivalTime = TextEditingController();
  final TextEditingController busID = TextEditingController();
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
                'Add New Bus Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter Bus Schedule below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              _buildTextField('Enter Schedule ID', schedID),
              _buildTextField('Select Route Name', routeID),
              _buildTextField('Select Departure Time', departureTime),
              _buildTextField('Select Arrival Time', arrivalTime),
              _buildTextField('Select Bus Number', busID),
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
