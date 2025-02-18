import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:bus/driverDashboard/settings.dart';
import 'package:bus/driverDashboard/driverprofile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class driverDashboard extends StatefulWidget {
  final String email;
  const driverDashboard({super.key, required this.email});

  @override
  _driverDashboardState createState() => _driverDashboardState();
}

class _driverDashboardState extends State<driverDashboard> {
  @override
  void initState() {
    super.initState();
    _loadCustomMarker(); // Load custom marker at initialization
    _fetchStudentData();
    _startDateTimeUpdater();
  }

  String? firstName;
  String? middleName;
  String? lastName;
  String gradeSection = '';
  String? timeBoarded;
  String? timeDropped;
  String? notificationMessage;
  String currentDateTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  Timer? _timer;

  void _startDateTimeUpdater() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _generateNotification() {
    print("Time Boarded: $timeBoarded");
    print("Time Dropped: $timeDropped");

    // If timeDropped is available and not 'Not Available', show 'Arrived at School'
    if (timeDropped != 'Not Available' && timeDropped != null) {
      return '$firstName has arrived at school at $timeDropped';
    } else if (timeDropped == 'Not Available') {
      return '$firstName has arrived at school at Not Available';
    }

    // Otherwise, if timeBoarded is available, show 'Boarded Bus'
    if (timeBoarded != 'Not Available' && timeBoarded != null) {
      return '$firstName has boarded the bus at $timeBoarded';
    } else if (timeBoarded == 'Not Available') {
      return '$firstName has boarded the bus at Not Available';
    }

    // Default message if no valid time is found
    return 'No updates available';
  }

  GoogleMapController? _controller;
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(7.7873416, 122.5852334), // Default coordinates
    zoom: 14.0,
  );

  final Set<Marker> _markers = {};
  BitmapDescriptor? customIcon;

  // Load custom marker from assets
  Future<void> _loadCustomMarker() async {
    final ByteData byteData =
        await rootBundle.load('assets/boy.png'); // Path to your image
    final Uint8List imageData = byteData.buffer.asUint8List();

    setState(() {
      customIcon = BitmapDescriptor.fromBytes(imageData);
    });
  }

  // Fetch student data from Firebase
  void _fetchStudentData() async {
    try {
      print("Fetching data for parent email: ${widget.email}");

      QuerySnapshot parentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (parentSnapshot.docs.isNotEmpty) {
        var parentDoc = parentSnapshot.docs.first;
        String studentID = parentDoc['studentID'];

        print("Student ID from Parent: $studentID");

        if (studentID.isNotEmpty) {
          QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('userType', isEqualTo: 'Student')
              .where('studentID', isEqualTo: studentID)
              .get();

          if (studentSnapshot.docs.isNotEmpty) {
            var studentDoc = studentSnapshot.docs.first;

            setState(() {
              firstName = studentDoc['firstName'] ?? 'No First Name';
              middleName = studentDoc['middleName'] ?? 'No Middle Name';
              lastName = studentDoc['lastName'] ?? 'No Last Name';
              gradeSection =
                  "${studentDoc['gradeLevel']} - ${studentDoc['strand']} - ${studentDoc['section']}";
              if (studentDoc['timeBoarded'] != null) {
                Timestamp timeBoardedTimestamp = studentDoc['timeBoarded'];
                DateTime timeBoardedDate = timeBoardedTimestamp.toDate();
                timeBoarded = DateFormat('h:mm a').format(timeBoardedDate);
              } else {
                timeBoarded = 'Not Available';
              }

              if (studentDoc['timeDropped'] != null) {
                Timestamp timeDroppedTimestamp = studentDoc['timeDropped'];
                DateTime timeDroppedDate = timeDroppedTimestamp.toDate();
                timeDropped = DateFormat('h:mm a').format(timeDroppedDate);
              } else {
                timeDropped = 'Not Available';
              }
            });
            notificationMessage = _generateNotification();

            if (studentDoc['currentLocation'] != null) {
              String currentLocation =
                  studentDoc['currentLocation']; // Latitude,Longitude
              List<String> coordinates = currentLocation.split(',');

              if (coordinates.length == 2) {
                double latitude = double.parse(coordinates[0].trim());
                double longitude = double.parse(coordinates[1].trim());

                _updateMap(latitude, longitude);
              } else {
                print("Invalid currentLocation format: $currentLocation");
              }
            } else {
              print("currentLocation field is missing for student.");
            }
          } else {
            print('No student document found with studentID: $studentID');
          }
        } else {
          print('No valid studentID found in parent document.');
        }
      } else {
        print('Parent document not found with email: ${widget.email}');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  // Update the map with the new coordinates
  void _updateMap(double latitude, double longitude) {
    if (customIcon == null) {
      print('Custom marker icon not loaded yet.');
      return;
    }

    LatLng newLocation = LatLng(latitude, longitude);

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('student_location'),
          position: newLocation,
          icon: customIcon!,
          infoWindow: const InfoWindow(title: 'Student Location'),
        ),
      );

      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 16.0),
      );
    });
  }

  void _navigateToAccountSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToStudents() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DriverProfile()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Hello Driver',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Account Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAccountSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Live Tracking",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "View Map",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Passengers",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Number of Student",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "23/25",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 300,
                            child: QrImageView(
                              data: currentDateTime,
                              version: QrVersions.auto,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
