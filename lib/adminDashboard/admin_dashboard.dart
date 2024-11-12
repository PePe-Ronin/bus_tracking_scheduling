import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late GoogleMapController _mapController;
  final LatLng _initialLocation =
      const LatLng(14.5995, 120.9842); // Example location

  // Function to handle map controller
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _navigateToProfile() {
    // Navigate to the profile screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _navigateToProfile();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialLocation,
                zoom: 14.0,
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
