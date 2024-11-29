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

  final _formKey = GlobalKey<FormState>();

  String? _userType;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
        final userData = {
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
        };

        // Save data to respective collections
        if (_userType == 'Student') {
          await _firestore
              .collection('students')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (_userType == 'Parent') {
          await _firestore
              .collection('parents')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
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
                                          _isPasswordHidden =
                                              !_isPasswordHidden;
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
                                TextFormField(
                                  controller: _lastName,
                                  decoration: const InputDecoration(
                                      labelText: 'Last Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your last name'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _firstName,
                                  decoration: const InputDecoration(
                                      labelText: 'First Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your first name'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _middleName,
                                  decoration: const InputDecoration(
                                      labelText: 'Middle Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your middle name'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _gradeLevel,
                                  decoration: const InputDecoration(
                                      labelText: 'Grade Level'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your grade level'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _section,
                                  decoration: const InputDecoration(
                                      labelText: 'Section'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your section'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _strand,
                                  decoration: const InputDecoration(
                                      labelText: 'Strand'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your strand'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _studentContact,
                                  decoration: const InputDecoration(
                                      labelText: 'Student Contact Number'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your contact number';
                                    } else if (!RegExp(r'^\d{10,11}$')
                                        .hasMatch(value)) {
                                      return 'Enter a valid contact number';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _parentName,
                                  decoration: const InputDecoration(
                                      labelText: 'Parent Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter parent name'
                                          : null,
                                ),
                                TextFormField(
                                  controller: _parentContact,
                                  decoration: const InputDecoration(
                                      labelText: 'Parent Contact Number'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter parent contact number';
                                    } else if (!RegExp(r'^\d{10,11}$')
                                        .hasMatch(value)) {
                                      return 'Enter a valid contact number';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _studentLatLNG,
                                  decoration: const InputDecoration(
                                      labelText: 'Student Location (Lat, Lng)'),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter your location'
                                          : null,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
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
