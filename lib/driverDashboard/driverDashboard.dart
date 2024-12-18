import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:bus/driverDashboard/settings.dart';
import 'package:bus/driverDashboard/driverprofile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class driverDashboard extends StatefulWidget {
  final String email;
  const driverDashboard({super.key, required this.email});

  @override
  _driverDashboardState createState() => _driverDashboardState();
}

class _driverDashboardState extends State<driverDashboard> {
  String? firstName;
  String? middleName;
  String? lastName;
  String gradeSection = '';
  String? timeBoarded;
  String? timeDropped;
  String? notificationMessage;

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

  @override
  void initState() {
    super.initState();
    _loadCustomMarker(); // Load custom marker at initialization
    _fetchStudentData();
  }

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: const Text(
            'Parent Dashboard',
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
                decoration: BoxDecoration(color: Colors.indigo),
                child: Text(
                  'Hello Parent',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              // ListTile(
              //   leading: const Icon(Icons.airline_seat_recline_normal_outlined),
              //   title: const Text('Students'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _navigateToStudents();
              //   },
              // ),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                'assets/student.png', // Placeholder for profile picture
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$firstName $middleName $lastName', // Dynamic student name
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  gradeSection, // Dynamic grade section
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Map replaces the image
                        SizedBox(
                          height: 200.0, // Adjust height as needed
                          child: GoogleMap(
                            initialCameraPosition: _initialPosition,
                            onMapCreated: (GoogleMapController controller) {
                              _controller = controller;
                            },
                            markers: _markers,
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.indigo),
                            SizedBox(width: 4),
                            Text(
                              'Currently at: School Bus',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Last updated: 2 minutes ago',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Today's Status
                const Text(
                  "Today's Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.directions_bus,
                                  color: Colors.white),
                              const SizedBox(height: 8),
                              const Text(
                                'Boarded Bus',
                                style: TextStyle(color: Colors.white),
                              ),
                              // Display the timeBoarded here
                              Text(
                                timeBoarded ?? 'Not Available',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.directions_bus,
                                  color: Colors.white),
                              const SizedBox(height: 8),
                              const Text(
                                'Arrived at School',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                timeDropped ?? 'Not Available',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recent Notifications
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                notificationMessage != null
                    ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2.0,
                        child: ListTile(
                          leading: const Icon(Icons.notifications,
                              color: Colors.teal),
                          title: Text(notificationMessage!),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
