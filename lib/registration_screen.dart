import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/dashboard.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _userType;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _gradeLevel = TextEditingController();
  final _section = TextEditingController();
  final _strand = TextEditingController();
  final _studentContact = TextEditingController();
  final _parentName = TextEditingController();
  final _parentContact = TextEditingController();
  final _studentLatLNG = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Show error dialog when passwords do not match
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    try {
      // Attempt to create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userType': _userType,
        'email': _emailController.text,
        'lastName': _lastName.text,
        'firstName': _firstName.text,
        'middleName': _middleName.text,
        'gradeLevel': _gradeLevel.text,
        'section': _section.text,
        'strand': _strand.text,
        'ContactNo': _studentContact.text,
        'parentName': _parentName.text,
        'parentContact': _parentContact.text,
        'studentLatLNG': _studentLatLNG.text,
        'confirmPassword': _confirmPasswordController.text,
      });

      // Redirect to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showErrorDialog(
            "The email is already in use. Please use a different email.");
      } else {
        // Handle other errors
        _showErrorDialog("An error occurred. Please try again.");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/edsa.png',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // 5% horizontal padding
                  vertical: screenHeight * 0.02, // 2% vertical padding
                ),
                child: Column(
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/bustii.png',
                        height: constraints.maxHeight * 0.2,
                        width: constraints.maxWidth * 0.5,
                      ),
                    ),
                    // Registration Form
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(top: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Register',
                                style: TextStyle(
                                  color: Color.fromRGBO(75, 57, 239, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                              DropdownButton<String>(
                                value: _userType,
                                hint: const Text('Please Select Role'),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    child: Text('Parent'),
                                    value: 'Parent',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Student'),
                                    value: 'Student',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Driver'),
                                    value: 'Driver',
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _userType = newValue;
                                  });
                                },
                              ),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                              ),
                              TextField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(75, 57, 239, 1),
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            screenHeight * 0.1), // Dynamic height at the bottom
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
