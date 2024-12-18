import 'package:bus/studentsDashboard/studentDashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class StudentConReg extends StatefulWidget {
  final String email;
  const StudentConReg({super.key, required this.email});

  @override
  State<StudentConReg> createState() => _StudentConRegState();
}

class _StudentConRegState extends State<StudentConReg> {
  final _studentID = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _gradeLevel = TextEditingController();
  final _section = TextEditingController();
  final _strand = TextEditingController();
  final _contactNumber = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _stopID = TextEditingController();

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  // Fetch the student's existing data based on email
  Future<void> _loadStudentData() async {
    try {
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: widget.email)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        var data = studentSnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          _studentID.text = data['studentID'];
          _lastName.text = data['lastName'];
          _firstName.text = data['firstName'];
          _middleName.text = data['middleName'];
          _gradeLevel.text = data['gradeLevel'];
          _section.text = data['section'];
          _strand.text = data['strand'];
          _contactNumber.text = data['contactNumber'];
          _address.text = data['address'];
          _email.text = data['email'];
          _stopID.text = data['stopID'];
        });
      } else {
        print("No student found with the given email.");
      }
    } catch (e) {
      print("Error loading student data: $e");
    }
  }

  // Save updated student data
  Future<void> _saveStudentData() async {
    if (_lastName.text.isEmpty ||
        _firstName.text.isEmpty ||
        _gradeLevel.text.isEmpty ||
        _section.text.isEmpty ||
        _strand.text.isEmpty ||
        _contactNumber.text.isEmpty ||
        _address.text.isEmpty ||
        _email.text.isEmpty ||
        _stopID.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
    } else {
      try {
        QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('email', isEqualTo: widget.email)
            .get();

        if (studentSnapshot.docs.isNotEmpty) {
          String docId = studentSnapshot.docs.first.id;

          await FirebaseFirestore.instance
              .collection('students')
              .doc(docId)
              .update({
            'studentID': _studentID.text,
            'lastName': _lastName.text,
            'firstName': _firstName.text,
            'middleName': _middleName.text,
            'gradeLevel': _gradeLevel.text,
            'section': _section.text,
            'strand': _strand.text,
            'contactNumber': _contactNumber.text,
            'address': _address.text,
            'email': _email.text,
            'stopID': _stopID.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Student information updated successfully!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDashboard(
                email: widget.email,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student not found.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openMapForAddress() async {
    LatLng initialLocation = await _getCurrentLocation();
    LatLng? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialLocation: initialLocation),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedLocation = selected;
        _address.text = "${selected.latitude}, ${selected.longitude}";
      });
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Information"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildTextField(_studentID, "Student ID"),
              _buildTextField(_lastName, "Last Name"),
              _buildTextField(_firstName, "First Name"),
              _buildTextField(_middleName, "Middle Name"),
              _buildTextField(_gradeLevel, "Grade Level"),
              _buildTextField(_section, "Section"),
              _buildTextField(_strand, "Strand"),
              _buildTextField(_contactNumber, "Contact Number"),
              _buildTextField(_email, "Email"),
              _buildTextField(_stopID, "Stop ID"),
              GestureDetector(
                onTap: _openMapForAddress,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _address,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: const Icon(Icons.map),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveStudentData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerScreen({required this.initialLocation, super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _markers = _getMarkerSet(_selectedLocation);
  }

  Set<Marker> _getMarkerSet(LatLng location) {
    return {
      Marker(
        markerId: const MarkerId('selected-location'),
        position: location,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
            _markers = _getMarkerSet(newPosition);
          });
        },
      ),
    };
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = _getMarkerSet(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _selectedLocation),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 16.0,
        ),
        markers: _markers,
        onTap: _onMapTapped,
      ),
    );
  }
}
