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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
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
