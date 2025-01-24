import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bus/login_screen.dart';
import 'package:bus/studentsDashboard/settings.dart';
import 'dart:ui' as ui;

class StudentDashboard extends StatefulWidget {
  final String email;

  const StudentDashboard({super.key, required this.email});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor? _studentMarkerIcon;
  BitmapDescriptor? _flagMarkerIcon;
  Set<Marker> _flagMarkers = {}; // Set to store all bus markers
  double _currentZoom = 9.0; // Default zoom level

  @override
  void initState() {
    super.initState();
    _loadstudentMarker();
    _loadflagMarker();
    _fetchBusRoutes(); // Fetch and display bus routes
    _fetchBusLocation();
  }

  Future<void> _loadstudentMarker() async {
    final BitmapDescriptor studentMarker =
        await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/boy.png',
    );
    setState(() {
      _studentMarkerIcon = studentMarker;
    });
  }

  Future<void> _loadflagMarker() async {
    final BitmapDescriptor flagMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/flag.png', // Ensure this path is correct
    );
    setState(() {
      _flagMarkerIcon = flagMarker;
    });
  }

  Future<void> _fetchBusLocation() async {
    try {
      final routesCollection = FirebaseFirestore.instance.collection('routes');
      final QuerySnapshot snapshot = await routesCollection.get();

      // Create a list to store the markers
      List<Marker> fetchedMarkers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> endPoint = data['busStatus'];
        final double latitude = endPoint['latitude'];
        final double longitude = endPoint['longitude'];
        final String busNumber = data['busNumber'];

        // Fetch the scaled marker icon asynchronously
        BitmapDescriptor markerIcon =
            await _getScaledMarkerIcon(1.0); // Pass zoom scale if needed

        // Create the Marker with the resolved icon
        final Marker marker = Marker(
          markerId: MarkerId(busNumber),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: 'Bus $busNumber'),
          icon: markerIcon, // Use the resolved scaled marker icon
        );

        fetchedMarkers.add(marker);
      }

      setState(() {
        _flagMarkers =
            Set.from(fetchedMarkers); // Update the markers in the state
      });
    } catch (e) {
      print('Error fetching bus routes: $e');
    }
  }

  Future<void> _fetchBusRoutes() async {
    try {
      final routesCollection = FirebaseFirestore.instance.collection('routes');
      final QuerySnapshot snapshot = await routesCollection.get();

      // Create a list to store the markers
      List<Marker> fetchedMarkers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> endPoint = data['endPoint'];
        final double latitude = endPoint['latitude'];
        final double longitude = endPoint['longitude'];
        final String busNumber = data['busNumber'];

        // Fetch the scaled marker icon asynchronously
        BitmapDescriptor markerIcon =
            await _getScaledMarkerIcon(1.0); // Pass zoom scale if needed

        // Create the Marker with the resolved icon
        final Marker marker = Marker(
          markerId: MarkerId(busNumber),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: 'Bus $busNumber'),
          icon: markerIcon, // Use the resolved scaled marker icon
        );

        fetchedMarkers.add(marker);
      }

      setState(() {
        _flagMarkers =
            Set.from(fetchedMarkers); // Update the markers in the state
      });
    } catch (e) {
      print('Error fetching bus routes: $e');
    }
  }

  Future<BitmapDescriptor> _getScaledMarkerIcon(double scale) async {
    // Load the image asset
    final ByteData data = await rootBundle.load('assets/flag.png');
    final List<int> bytes = data.buffer.asUint8List();

    // Decode the image
    final ui.Image image = await decodeImageFromList(Uint8List.fromList(bytes));

    // Resize the image based on the scale
    final ui.Image resizedImage = await _resizeImage(image, scale);

    // Convert the resized image to a BitmapDescriptor
    final ByteData? resizedImageBytes =
        await resizedImage.toByteData(format: ui.ImageByteFormat.png);

    // Check if the resized image bytes are null before proceeding
    if (resizedImageBytes == null) {
      throw Exception('Failed to convert resized image to byte data.');
    }

    final Uint8List resizedImageList =
        Uint8List.fromList(resizedImageBytes.buffer.asUint8List());
    return BitmapDescriptor.fromBytes(resizedImageList);
  }

  Future<ui.Image> _resizeImage(ui.Image image, double scale) async {
    // Calculate the new width and height based on the scale factor
    final int newWidth = (image.width * scale).toInt();
    final int newHeight = (image.height * scale).toInt();

    // Create a new PictureRecorder and Canvas to draw the resized image
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0, 0),
            Offset(newWidth.toDouble(), newHeight.toDouble())));

    // Create a Paint object
    final Paint paint = Paint();

    // Draw the image on the canvas with the new size
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        paint);

    // End recording the picture and convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image resizedImage = await picture.toImage(newWidth, newHeight);

    return resizedImage;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentZoom = position.zoom;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToAccountSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Student Dashboard',
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
                'Hello Student',
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(7.7873416, 122.5852334),
                            zoom: 9.0,
                          ),
                          markers: _flagMarkers, // Use fetched bus markers
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          onCameraMove:
                              _onCameraMove, // Listen for zoom changes
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bus #2371',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Estimated arrival: 5 minutes',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.directions_bus,
                            size: 32,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Journey",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.place, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('123 Maple Street'),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.place, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Springfield Elementary'),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('7:15 AM'),
                              SizedBox(height: 16),
                              Text('7:45 AM'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          QuickActionButton(
                            icon: Icons.qr_code,
                            label: 'Scan QR Code',
                            color: Colors.purple,
                          ),
                          QuickActionButton(
                            icon: Icons.notifications,
                            label: 'Notifications',
                            color: Colors.orange,
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

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color ?? Colors.grey[300],
          radius: 28,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
