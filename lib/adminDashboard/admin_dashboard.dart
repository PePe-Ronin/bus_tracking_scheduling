import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus/adminDashboard/settings.dart';
import 'package:bus/adminDashboard/drivers.dart';
import 'package:bus/adminDashboard/parents.dart';
import 'package:bus/adminDashboard/students.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ignore: unused_field
  late GoogleMapController _mapController;
  final LatLng _initialLocation =
      const LatLng(7.785552035561738, 122.5863163838556); // Example location

  // Function to handle map controller
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _navigateToSettings() {
    // Navigate to the settings screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  void _navigateToDrivers() {
    // Navigate to the drivers screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DriverScreen()));
  }

  void _navigateToParents() {
    // Navigate to the parent screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ParentScreen()));
  }

  void _navigateToStudents() {
    // Navigate to the student screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => StudentScreen()));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Hamburger icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Hello Admin',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Drivers'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToDrivers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Parents'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToParents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.airline_seat_recline_normal_outlined),
              title: const Text('Students'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToStudents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialLocation,
                zoom: 17.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('initialLocation'),
                  position: _initialLocation,
                  infoWindow: const InfoWindow(title: 'Admin Location'),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
