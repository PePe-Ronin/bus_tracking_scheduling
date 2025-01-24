import 'package:bus/parentDashboard/parentDashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ParentConReg extends StatefulWidget {
  final String email;
  const ParentConReg({super.key, required this.email});

  @override
  State<ParentConReg> createState() => _ParentConRegState();
}

class _ParentConRegState extends State<ParentConReg> {
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _contactNumber = TextEditingController();
  final _address = TextEditingController();
  final _studentID = TextEditingController();
  final _email = TextEditingController();

  LatLng? _selectedLocation;
  bool _isStudentIDValid = true;

  @override
  void initState() {
    super.initState();
    _loadparentData();
  }

  // Fetch the parent's existing data based on email
  Future<void> _loadparentData() async {
    try {
      QuerySnapshot parentSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .where('email', isEqualTo: widget.email)
          .get();

      if (parentSnapshot.docs.isNotEmpty) {
        var data = parentSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _lastName.text = data['lastName'];
          _firstName.text = data['firstName'];
          _middleName.text = data['middleName'];
          _studentID.text = data['studentID'];
          _contactNumber.text = data['contactNumber'];
          _selectedLocation = data['address'];
        });
      } else {
        print("No parent found with the given email.");
      }
    } catch (e) {
      print("Error loading parent data: $e");
    }
  }

  // Verify if the student ID exists in the 'users' collection
  Future<void> _verifyStudentID(String studentID) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('studentID', isEqualTo: studentID)
          .get();

      setState(() {
        _isStudentIDValid = userSnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print("Error verifying student ID: $e");
    }
  }

  // Save updated parent data
  Future<void> _saveparentData() async {
    if (!_isStudentIDValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Student ID. Please verify.')),
      );
      return;
    }

    if (_lastName.text.isEmpty ||
        _firstName.text.isEmpty ||
        _address.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      QuerySnapshot parentSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .where('email', isEqualTo: widget.email)
          .get();

      if (parentSnapshot.docs.isNotEmpty) {
        String docId = parentSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('parents')
            .doc(docId)
            .update({
          'lastName': _lastName.text,
          'firstName': _firstName.text,
          'middleName': _middleName.text,
          'studentID': _studentID.text,
          'contactNumber': _contactNumber.text,
          'address': _address.text,
          'email': _email.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Parent information updated successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ParentDashboard(email: ""),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Information"),
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
              TextFormField(
                controller: _lastName,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstName,
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _middleName,
                decoration: InputDecoration(
                  labelText: "Middle Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentID,
                decoration: InputDecoration(
                  labelText: "Student ID Number",
                  errorText:
                      _isStudentIDValid ? null : 'Student ID does not exist',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _verifyStudentID(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumber,
                decoration: InputDecoration(
                  labelText: "Parent Contact Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                onPressed: _saveparentData,
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
      appBar: AppBar(title: const Text('Select Address')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 16.0,
        ),
        markers: _markers,
        onTap: _onMapTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _selectedLocation),
        label: const Text('Confirm'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
