import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/adminDashboard/admin_dashboard.dart';
import 'package:bus/parentDashboard/parent_dashboard.dart';
import 'package:bus/registration_screen.dart';
import 'package:bus/forgotpassword.dart';
import 'package:bus/studentsDashboard/student_dashboard.dart';
import 'package:bus/driverDashboard/driver_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // Login method
  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            String userType = userDoc['userType'];

            if (userType == "Administrator") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            } else if (userType == "Parent") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ParentDashboard()),
              );
            } else if (userType == "Student") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const StudentDashboard()),
              );
            } else if (userType == "Driver") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DriverDashboard()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unknown user type')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found')),
            );
          }
        }
      } catch (e) {
        String errorMessage = 'Login failed. Please try again.';
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found for that email.';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Incorrect password. Please try again.';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
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
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/bustii.png',
                    height: screenHeight * 0.2,
                    width: screenWidth * 0.5,
                  ),
                ),
                Form(
                  key: _formKey,
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
                          'Login',
                          style: TextStyle(
                            color: Color.fromRGBO(75, 57, 239, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                                color: Color.fromRGBO(75, 57, 239, 1)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(75, 57, 239, 1),
                                  width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(75, 57, 239, 1),
                                  width: 2),
                            ),
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                                color: Color.fromRGBO(75, 57, 239, 1)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(75, 57, 239, 1),
                                  width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(75, 57, 239, 1),
                                  width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromRGBO(75, 57, 239, 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(75, 57, 239, 1),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color.fromRGBO(75, 57, 239, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
