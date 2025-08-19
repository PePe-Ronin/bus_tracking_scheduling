import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> saveStopToFirebase() async {
    if (stopID.text.isEmpty ||
        latlng.text.isEmpty ||
        routeID.text.isEmpty ||
        status.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email:
            'admin@example.com', // Replace with actual admin email or pass as parameter
        password: passwordController.text,
      );

      final stopData = {
        'stopID': stopID.text,
        'latlng': latlng.text,
        'routeID': routeID.text,
        'status': status.text,
      };

      await FirebaseFirestore.instance
          .collection('stops')
          .doc(userCredential.user!.uid)
          .set(stopData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save stop: $e')),
      );
    }
  }

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
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: saveStopToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(75, 57, 239, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
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
