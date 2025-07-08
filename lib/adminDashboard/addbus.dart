import 'package:bus/adminDashboard/adminDashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class addBus extends StatefulWidget {
  final String adminEmail;
  final String adminPassword;
  const addBus(
      {super.key, required this.adminEmail, required this.adminPassword});

  @override
  State<addBus> createState() => _addBusState();
}

class _addBusState extends State<addBus> {
  String? _selectedDriver;
  List<String> _driver = [];

  final TextEditingController _busID = TextEditingController();
  final TextEditingController _plateNumber = TextEditingController();
  final TextEditingController _capacity = TextEditingController();
  final TextEditingController _driverID = TextEditingController();
  final String password = "stiibus2024";
  final _auth = FirebaseAuth.instance;

  Future<void> _fetchDriver() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('driver').get();

      List<String> fetchedDriver = snapshot.docs.map((doc) {
        String firstName = doc['firstName'] ?? '';
        String middleName = doc['middleName'] ?? '';
        String lastName = doc['lastName'] ?? '';
        return '$firstName $middleName $lastName'.trim();
      }).toList();

      setState(() {
        _driver = fetchedDriver;
      });
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bus: $e')),
      );
    }
  }

  Future<void> saveBusToFirebase() async {
    // Get the values from the text controllers
    final busData = {
      'busID': _busID.text,
      'plateNumber': _plateNumber.text,
      'capacity': _capacity.text,
      'driver': _driverID.text,
    };

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: widget.adminEmail,
        password: widget.adminPassword,
      );

      // Save the data to Firestore

      await FirebaseFirestore.instance
          .collection('bus')
          .doc(userCredential.user!.uid)
          .set(busData);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus details saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MapAdmin(
                  adminEmail: widget.adminEmail,
                  adminPassword: widget.adminPassword,
                )),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save bus details: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDriver(); // Fetch driver list when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Bus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              const SizedBox(height: 8),
              const Text(
                'Enter Bus details below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildTextField('Bus ID', _busID),
              _buildTextField('Plate Number', _plateNumber),
              _buildTextField('Capacity', _capacity),
              DropdownButtonFormField<String>(
                value: _selectedDriver,
                items: _driver.map((driver) {
                  return DropdownMenuItem(
                    value: driver,
                    child: Text(driver),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDriver = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Bus Driver",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Center(
                child: Container(
                  child: ElevatedButton(
                    onPressed: saveBusToFirebase,
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
