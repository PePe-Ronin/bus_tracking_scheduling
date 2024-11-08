import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/welcome_screen.dart';

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

  void _register() async {
    try {
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          // Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              color: Colors.white.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Set up your account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding:
                    const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0),
                child: Column(
                  children: [
                    // Logo
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Image.asset(
                          'assets/bustii.png',
                          height: constraints.maxHeight * 0.2,
                          width: constraints.maxWidth * 0.5,
                        ),
                      ),
                    ),
                    // Registration Form
                    Expanded(
                      flex: 6,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                            ),
                            TextField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'Confirm Password'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
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
                    SizedBox(height: screenHeight * 0.1), // Dynamic height
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
