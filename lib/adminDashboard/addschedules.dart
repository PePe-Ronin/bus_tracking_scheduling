import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> saveScheduleToFirebase() async {
    if (schedID.text.isEmpty ||
        routeID.text.isEmpty ||
        departureTime.text.isEmpty ||
        arrivalTime.text.isEmpty ||
        busID.text.isEmpty) {
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

      final scheduleData = {
        'scheduleID': schedID.text,
        'routeID': routeID.text,
        'departureTime': departureTime.text,
        'arrivalTime': arrivalTime.text,
        'busID': busID.text,
      };

      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(userCredential.user!.uid)
          .set(scheduleData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save schedule: $e')),
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
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: saveScheduleToFirebase,
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
