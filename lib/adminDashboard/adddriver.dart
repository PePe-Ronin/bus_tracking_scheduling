import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/adminDashboard/drivers.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({super.key});

  @override
  State<AddDriver> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriver> {
  // Controllers for text fields
  final TextEditingController driverLastName = TextEditingController();
  final TextEditingController driverFirstName = TextEditingController();
  final TextEditingController driverMiddleName = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed
    driverLastName.dispose();
    driverFirstName.dispose();
    driverMiddleName.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    super.dispose();
  }

  Future<void> saveDriverToFirebase() async {
    // Get the values from the text controllers
    final driverData = {
      'lastName': driverLastName.text,
      'firstName': driverFirstName.text,
      'middleName': driverMiddleName.text,
      'phoneNumber': phoneNumberController.text,
      'email': emailController.text,
      'password': "stiibus2024",
      'licenseNumber': licenseNumberController.text,
      'licenseExpiryDate': licenseExpiryController.text,
      'status': "Offline",
      'dateAdded': DateTime.now(),
    };

    try {
      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('drivers').add(driverData);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver details saved successfully!')),
      );

      // Clear the fields after saving
      driverLastName.clear();
      driverFirstName.clear();
      driverMiddleName.clear();
      phoneNumberController.clear();
      emailController.clear();
      licenseNumberController.clear();
      licenseExpiryController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverScreen()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save driver details: $e')),
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
              Text(
                'Add New Driver',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enter driver details below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                          'assets/profile.png'), // Replace with appropriate asset
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.blue),
                        onPressed: () {
                          // Add photo upload logic here
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Last Name', driverLastName),
              _buildTextField('First Name', driverFirstName),
              _buildTextField('Middle Name', driverMiddleName),
              _buildTextField(
                'Phone Number',
                phoneNumberController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                'Email',
                emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField('License Number', licenseNumberController),
              SizedBox(height: 20),
              Text(
                'License Expiry Date',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      licenseExpiryController.text =
                          "${selectedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        licenseExpiryController.text.isEmpty
                            ? 'Select Date'
                            : licenseExpiryController.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: licenseExpiryController.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: saveDriverToFirebase,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: Text('Save Driver'),
                ),
              ),
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