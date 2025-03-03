import 'package:bus/adminDashboard/addroute.dart';
import 'package:bus/adminDashboard/addstops.dart';
import 'package:bus/adminDashboard/viewparentregistration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus/adminDashboard/settings.dart';
import 'package:bus/adminDashboard/drivers.dart';
import 'package:bus/adminDashboard/addschedules.dart';
import 'package:bus/adminDashboard/viewstudentregistration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bus/adminDashboard/addbus.dart';

class MapAdmin extends StatefulWidget {
  final String adminEmail;
  final String adminPassword;
  const MapAdmin(
      {super.key, required this.adminEmail, required this.adminPassword});

  @override
  _MapAdminState createState() => _MapAdminState();
}

class _MapAdminState extends State<MapAdmin> {
  late GoogleMapController _mapController;
  final LatLng _initialLocation =
      const LatLng(7.785552035561738, 122.5863163838556); // Example location

  final Set<Marker> _markers = {};

  // Function to handle map controller
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _enableLocation(); // Enable location layer after map is created
  }

  // Request location permissions
  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, enable MyLocation layer
      setState(() {
        _mapController.setMapStyle(''); // Set map style if needed
      });
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
    }
  }

  // Enable MyLocation layer
  void _enableLocation() async {
    await _requestLocationPermission();
    setState(() {
      // Enable MyLocation feature on the map
      _mapController.setMapStyle(''); // You can apply a map style if needed
    });
  }

  Stream<List<RouteData>> getRoutes() {
    return FirebaseFirestore.instance.collection('routes').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RouteData.fromFirestore(doc.data()))
            .toList());
  }

  void _navigateToSettings() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToDrivers() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DriverScreen()));
  }

  void _navigateToStops() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Addstops()));
  }

  void _navigateToBus() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => addBus(
                  adminEmail: widget.adminEmail,
                  adminPassword: widget.adminPassword,
                )));
  }

  void _navigateToRoutes() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Addroute(
                  adminEmail: widget.adminEmail,
                  adminPassword: widget.adminPassword,
                )));
  }

  void _navigateToParents() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ParentRegistrations()));
  }

  void _navigateToStudents() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StudentRegistration()));
  }

  void _navigateToSchedules() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Addschedules()));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Add route method for navigating to the "Add Route" page
  void _navigateToAddRoute() {
    // Navigate to a page for adding a new route (this page should be implemented)
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Addroute(
                adminEmail: widget.adminEmail,
                adminPassword: widget.adminPassword,
              )), // Replace with your add route screen
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
              title: const Text('Buses'),
              onTap: () {
                Navigator.pop(context);
                _navigateToBus();
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Routes'),
              onTap: () {
                Navigator.pop(context);
                _navigateToRoutes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Stops'),
              onTap: () {
                Navigator.pop(context);
                _navigateToStops();
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Drivers'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDrivers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Parents'),
              onTap: () {
                Navigator.pop(context);
                _navigateToParents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.airline_seat_recline_normal_outlined),
              title: const Text('Students'),
              onTap: () {
                Navigator.pop(context);
                _navigateToStudents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 300,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialLocation,
                  zoom: 9,
                ),
                markers: _markers,
                myLocationEnabled: true, // Enable the MyLocation layer
                myLocationButtonEnabled:
                    true, // Optional: enable MyLocation button
                mapType: MapType.normal,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Scheduled routes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<RouteData>>(
              stream: getRoutes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final routes = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return RouteCard(
                      routeName: route.routeName,
                      driver: 'Driver: ${route.driver}',
                      busNumber: 'Bus Number: ${route.busNumber}',
                    );
                  },
                );
              },
            ),
          ),
          // "Add Route" button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ElevatedButton(
              onPressed:
                  _navigateToAddRoute, // Navigate to the Add Route screen
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Add Route',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String routeName;
  final String driver;
  final String busNumber;

  const RouteCard({
    super.key,
    required this.routeName,
    required this.driver,
    required this.busNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.directions_bus, size: 28, color: Colors.black),
        ),
        title: Text(
          routeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$driver\n$busNumber',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class RouteData {
  final String routeName;
  final String driver;
  final String busNumber;

  RouteData({
    required this.routeName,
    required this.driver,
    required this.busNumber,
  });

  // Factory method to create a RouteData from Firestore data
  factory RouteData.fromFirestore(Map<String, dynamic> firestoreData) {
    return RouteData(
      routeName: firestoreData['routeName'],
      driver: firestoreData['driver'],
      busNumber: firestoreData['busNumber'],
    );
  }
}

@override
Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.directions_bus, size: 28, color: Colors.black),
      ),
    ),
  );
}
