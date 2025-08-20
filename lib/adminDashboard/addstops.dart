import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Addstops extends StatefulWidget {
  final String adminEmail;
  final String adminPassword;
  const Addstops(
      {super.key, required this.adminEmail, required this.adminPassword});

  @override
  State<Addstops> createState() => _AddstopsState();
}

class _AddstopsState extends State<Addstops> {
  final TextEditingController stopID = TextEditingController();
  final TextEditingController status = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? selectedRouteId;
  String? selectedRouteName;
  List<Map<String, dynamic>> availableRoutes = [];
  bool isLoadingRoutes = true;

  // Location picker variables
  LatLng? selectedLocation;
  String? locationAddress;
  LatLng? startPoint;
  LatLng? endPoint;
  bool isLoadingRouteDetails = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableRoutes();
  }

  Future<void> fetchAvailableRoutes() async {
    try {
      final QuerySnapshot routesSnapshot =
          await FirebaseFirestore.instance.collection('routes').get();

      setState(() {
        availableRoutes = routesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'routeName': data['routeName'] ?? 'Unnamed Route',
            'startPoint': data['startingPoint'],
            'endPoint': data['endPoint'],
          };
        }).toList();
        isLoadingRoutes = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRoutes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load routes: $e')),
      );
    }
  }

  Future<void> saveStopToFirebase() async {
    if (stopID.text.isEmpty ||
        selectedLocation == null ||
        selectedRouteId == null ||
        status.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: widget.adminEmail,
        password: widget.adminPassword,
      );

      final stopData = {
        'stopID': stopID.text,
        'latlng':
            '${selectedLocation!.latitude},${selectedLocation!.longitude}',
        'locationAddress': locationAddress ?? '',
        'routeID': selectedRouteId,
        'routeName': selectedRouteName,
        'status': status.text,
      };

      await FirebaseFirestore.instance
          .collection('stops')
          .doc(userCredential.user!.uid)
          .set(stopData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save stop: $e')),
      );
    }
  }

  void _onRouteSelected(String? routeId) {
    if (routeId == null) return;

    final selectedRoute = availableRoutes.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => {},
    );

    if (selectedRoute.isNotEmpty) {
      setState(() {
        selectedRouteId = routeId;
        selectedRouteName = selectedRoute['routeName'];

        // Parse start and end points with better error handling
        final startData = selectedRoute['startPoint'];
        final endData = selectedRoute['endPoint'];

        print('Selected route: $selectedRouteName');
        print('Start data: $startData');
        print('End data: $endData');

        if (startData != null && endData != null) {
          try {
            // Handle both Map<String, dynamic> and GeoPoint formats
            double startLat, startLng, endLat, endLng;

            if (startData is Map<String, dynamic>) {
              startLat =
                  (startData['latitude'] ?? startData['lat'] ?? 0.0).toDouble();
              startLng = (startData['longitude'] ?? startData['lng'] ?? 0.0)
                  .toDouble();
            } else if (startData is GeoPoint) {
              startLat = startData.latitude;
              startLng = startData.longitude;
            } else {
              throw Exception('Invalid start point format');
            }

            if (endData is Map<String, dynamic>) {
              endLat =
                  (endData['latitude'] ?? endData['lat'] ?? 0.0).toDouble();
              endLng =
                  (endData['longitude'] ?? endData['lng'] ?? 0.0).toDouble();
            } else if (endData is GeoPoint) {
              endLat = endData.latitude;
              endLng = endData.longitude;
            } else {
              throw Exception('Invalid end point format');
            }

            startPoint = LatLng(startLat, startLng);
            endPoint = LatLng(endLat, endLng);

            print('Successfully parsed start: $startPoint, end: $endPoint');
          } catch (e) {
            print('Error parsing coordinates: $e');
            startPoint =
                const LatLng(14.5995, 120.9842); // Default Manila coordinates
            endPoint = const LatLng(
                14.6760, 121.0437); // Default Quezon City coordinates
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Using default coordinates: ${e.toString()}'),
              ),
            );
          }
        } else {
          print('Start or end data is null, using defaults');
          startPoint =
              const LatLng(14.5995, 120.9842); // Default Manila coordinates
          endPoint = const LatLng(
              14.6760, 121.0437); // Default Quezon City coordinates
        }
      });
    }
  }

  void _openLocationPicker() async {
    if (startPoint == null || endPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a route first')),
      );
      return;
    }

    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          startPoint: startPoint!,
          endPoint: endPoint!,
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        selectedLocation = pickedLocation;
        locationAddress =
            'Lat: ${pickedLocation.latitude.toStringAsFixed(4)}, Lng: ${pickedLocation.longitude.toStringAsFixed(4)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Bus Stops',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter Bus Stops below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              _buildTextField('Enter Stop Name', stopID),
              _buildRouteDropdown(),
              _buildLocationPicker(),
              _buildTextField('Set Status', status),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: saveStopToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(75, 57, 239, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDropdown() {
    if (isLoadingRoutes) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (availableRoutes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'No routes available',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabled: false,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedRouteId,
        decoration: InputDecoration(
          labelText: 'Select Route',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: availableRoutes.map((route) {
          return DropdownMenuItem<String>(
            value: route['id'],
            child: Text(route['routeName']),
          );
        }).toList(),
        onChanged: _onRouteSelected,
        validator: (value) {
          if (value == null) {
            return 'Please select a route';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Stop Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _openLocationPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLocation != null
                          ? locationAddress ?? 'Location selected'
                          : 'Tap to select location on map',
                      style: TextStyle(
                        color: selectedLocation != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          if (selectedRouteId == null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Select a route first to view map',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng startPoint;
  final LatLng endPoint;

  const LocationPickerScreen({
    super.key,
    required this.startPoint,
    required this.endPoint,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _isMapReady = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController.dispose();
    super.dispose();
  }

  void _initializeMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('startPoint'),
        position: widget.startPoint,
        infoWindow: const InfoWindow(title: 'Route Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('endPoint'),
        position: widget.endPoint,
        infoWindow: const InfoWindow(title: 'Route End'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_isDisposed) return;

    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });

    // Optimize camera bounds calculation
    _moveCameraToRouteBounds();
  }

  void _moveCameraToRouteBounds() {
    if (_isDisposed) return;

    try {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _min(widget.startPoint.latitude, widget.endPoint.latitude) - 0.005,
          _min(widget.startPoint.longitude, widget.endPoint.longitude) - 0.005,
        ),
        northeast: LatLng(
          _max(widget.startPoint.latitude, widget.endPoint.latitude) + 0.005,
          _max(widget.startPoint.longitude, widget.endPoint.longitude) + 0.005,
        ),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      // Fallback to center point
      final center = LatLng(
        (widget.startPoint.latitude + widget.endPoint.latitude) / 2,
        (widget.startPoint.longitude + widget.endPoint.longitude) / 2,
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(center, 12),
      );
    }
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;

  void _onMapTap(LatLng position) {
    if (_isDisposed) return;

    setState(() {
      _selectedLocation = position;

      // Update markers efficiently
      _markers =
          Set.from(_markers.where((m) => m.markerId.value != 'selected'));
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Stop',
            snippet:
                'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _onConfirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Stop Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _onConfirmSelection,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.startPoint.latitude + widget.endPoint.latitude) / 2,
                (widget.startPoint.longitude + widget.endPoint.longitude) / 2,
              ),
              zoom: 11,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: true,
            liteModeEnabled: false,
          ),
          if (!_isMapReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _onConfirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _selectedLocation != null
                    ? 'Confirm Location'
                    : 'Tap on map to select location',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
