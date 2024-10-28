import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bus/welcome_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _gradeLevel = TextEditingController();
  final _section = TextEditingController();
  final _strand = TextEditingController();
  final _parentName = TextEditingController();
  final _parentContact = TextEditingController();
  final _studentLatLNG = TextEditingController();

  void _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      print('Error: $e'); // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(98, 149, 132, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/bustii.png',
                height: 200,
                width: 200, // Set your desired height here
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(226, 241, 231, 1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
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
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
