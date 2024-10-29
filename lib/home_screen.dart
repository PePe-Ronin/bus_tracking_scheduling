import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus/welcome_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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

  void _register() async {
    try {
      // Register user with Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // After successful registration, save additional user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'lastName': _lastName.text,
        'firstName': _firstName.text,
        'middleName': _middleName.text,
        'gradeLevel': _gradeLevel.text,
        'section': _section.text,
        'strand': _strand.text,
        'studentContact': _studentContact,
        'parentName': _parentName.text,
        'parentContact': _parentContact.text,
        'studentLatLNG': _studentLatLNG.text,
      });

      // Navigate to the Welcome screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      print(
          'Error: $e'); // Handle error (can show a dialog or toast in production)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Set up your account",
            textAlign: TextAlign.center,
          ),
        ),
        leading: IconButton(
            onPressed: () {}, icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/bustii.png',
                height: 200,
                width: 200,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _lastName,
                      decoration: InputDecoration(labelText: 'Last Name'),
                    ),
                    TextField(
                      controller: _firstName,
                      decoration: InputDecoration(labelText: 'First Name'),
                    ),
                    TextField(
                      controller: _middleName,
                      decoration: InputDecoration(labelText: 'Middle Name'),
                    ),
                    TextField(
                      controller: _gradeLevel,
                      decoration: InputDecoration(labelText: 'Grade Level'),
                    ),
                    TextField(
                      controller: _section,
                      decoration: InputDecoration(labelText: 'Section'),
                    ),
                    TextField(
                      controller: _strand,
                      decoration: InputDecoration(labelText: 'Strand'),
                    ),
                    TextField(
                      controller: _studentContact,
                      decoration:
                          InputDecoration(labelText: 'Student Contact No.'),
                    ),
                    TextField(
                      controller: _parentName,
                      decoration: InputDecoration(labelText: "Parent's Name"),
                    ),
                    TextField(
                      controller: _parentContact,
                      decoration:
                          InputDecoration(labelText: "Parent's Contact No."),
                    ),
                    TextField(
                      controller: _studentLatLNG,
                      decoration: InputDecoration(labelText: "LATLNG"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text(
                  'Register',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
