import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/adminDashboard/adminDashboard.dart';
import 'package:bus/parentDashboard/parentRegistration.dart';
import 'package:bus/studentsDashboard/studentRegistration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  String? _userType;
  final _emailController = TextEditingController();
  final _studentID = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _section = TextEditingController();
  final _contactNumber = TextEditingController();
  final _address = TextEditingController();
  final _name = TextEditingController();
  final _confirmPass = TextEditingController();

  String? _gradeLevel;
  String? _strand;
  LatLng? _selectedLocation;

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  void _showErrorPrompt(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorPrompt("Passwords do not match.");
        return;
      }

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Prepare common user data

        // Save data to respective collections
        if (_userType == 'Student') {
          final userData = {
            'userType': _userType ?? '', // Provide default value if null
            'email': _emailController.text.isEmpty
                ? null
                : _emailController.text, // If empty, set as null
            'lastName':
                _lastName.text.isEmpty ? null : _lastName, // Check if empty
            'firstName':
                _firstName.text.isEmpty ? null : _firstName, // Check if empty
            'middleName':
                _middleName.text.isEmpty ? null : _middleName, // Check if empty
            'section':
                _section.text.isEmpty ? null : _section, // Check if empty
            'gradeLevel': _gradeLevel ?? '',
            'strand': _strand ?? '',
            'contactNumber': _contactNumber.text.isEmpty
                ? null
                : _contactNumber, // Check if empty
            'address': _selectedLocation != null
                ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}' // Save coordinates if location is selected
                : null, // If location is not selected, save null
          };
          await _firestore
              .collection('students')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (_userType == 'Parent') {
          final userData = {
            'userType': _userType ?? '', // Provide default value if null
            'email': _emailController.text.isEmpty
                ? null
                : _emailController.text, // If empty, set as null
            'lastName':
                _lastName.text.isEmpty ? null : _lastName, // Check if empty
            'firstName':
                _firstName.text.isEmpty ? null : _firstName, // Check if empty
            'middleName': _middleName.text.isEmpty ? null : _middleName,
            'studentID': _studentID.text.isEmpty ? null : _studentID,
            'contactNumber': _contactNumber.text.isEmpty
                ? null
                : _contactNumber, // Check if empty
            'address': _selectedLocation != null
                ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}' // Save coordinates if location is selected
                : null, // If location is not selected, save null
          };
          await _firestore
              .collection('parents')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (_userType == 'Admin') {
          final userData = {
            'userType': _userType ?? '', // Provide default value if null
            'email': _emailController.text.isEmpty
                ? null
                : _emailController.text, // If empty, set as null
            'name': _lastName.text.isEmpty ? null : _lastName, // Check if empty
            'number': _contactNumber.text.isEmpty
                ? null
                : _contactNumber, // Check if empty
            'confirmPass': _confirmPass.text.isEmpty ? null : _confirmPass.text,
          };
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);
        }

        // Navigate to the correct dashboard with email passed
        if (_userType == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapAdmin()),
          );
        } else if (_userType == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentConReg(
                email: _emailController.text,
              ),
            ),
          );
        } else if (_userType == 'Parent') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ParentConReg(email: _emailController.text),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _showErrorPrompt(
              "The email is already in use. Please use a different email.");
        } else {
          _showErrorPrompt("An error occurred. Please try again.");
        }
      } catch (e) {
        _showErrorPrompt("An unexpected error occurred. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
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
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/bustii.png',
                        height: constraints.maxHeight * 0.2,
                        width: constraints.maxWidth * 0.5,
                      ),
                    ),
                    SingleChildScrollView(
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
                        child: Form(
                          key: _formKey,
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
                              DropdownButtonFormField<String>(
                                value: _userType,
                                hint: const Text('Please Select Role'),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Parent',
                                    child: Text('Parent'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Student',
                                    child: Text('Student'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _userType = newValue;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Please select a role'
                                    : null,
                              ),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordHidden = !_isPasswordHidden;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _isPasswordHidden,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordHidden =
                                            !_isConfirmPasswordHidden;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _isConfirmPasswordHidden,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  } else if (value !=
                                      _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(75, 57, 239, 1),
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Center(
                                  child: GestureDetector(
                                onTap: () {
                                  // Navigate to the login screen (or whichever screen you'd like)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromRGBO(75, 57, 239, 1),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
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
