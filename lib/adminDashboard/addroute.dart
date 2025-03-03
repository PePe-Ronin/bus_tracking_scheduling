import 'package:bus/adminDashboard/adminDashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Addroute extends StatefulWidget {
  final String adminEmail;
  final String adminPassword;
  const Addroute(
      {super.key, required this.adminEmail, required this.adminPassword});

  @override
  State<Addroute> createState() => _AddrouteState();
}

class _AddrouteState extends State<Addroute> {
  String? _selectedDriver;
  List<String> _drivers = [];
  bool _isLoading = true;

  final TextEditingController _routeID = TextEditingController();
  final TextEditingController _routeName = TextEditingController();
  final TextEditingController _busID = TextEditingController();
  final TextEditingController _startingPoint = TextEditingController();
  final TextEditingController _endPoint = TextEditingController();

  LatLng? _startingPointLocation;
  LatLng? _endPointLocation;

  @override
  void initState() {
    super.initState();
    _fetchBus();
  }

  Future<void> _fetchBus() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('bus').get();

      List<String> fetchedDrivers = snapshot.docs.map((doc) {
        String firstName = doc['firstName'] ?? '';
        String middleName = doc['middleName'] ?? '';
        String lastName = doc['lastName'] ?? '';
        return '$firstName $middleName $lastName'.trim();
      }).toList();

      setState(() {
        _drivers = fetchedDrivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching drivers: $e')),
      );
    }
  }

  Future<void> _openMapForLocation(bool isStartingPoint) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: isStartingPoint
              ? _startingPointLocation ??
                  const LatLng(7.785552035561738, 122.5863163838556)
              : _endPointLocation ??
                  const LatLng(7.785552035561738, 122.5863163838556),
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        if (isStartingPoint) {
          _startingPointLocation = selectedLocation;
          _startingPoint.text =
              '${selectedLocation.latitude}, ${selectedLocation.longitude}';
        } else {
          _endPointLocation = selectedLocation;
          _endPoint.text =
              '${selectedLocation.latitude}, ${selectedLocation.longitude}';
        }
      });
    }
  }

  Future<void> _submitBusRoutes() async {
    if (_routeID.text.isEmpty ||
        _busID.text.isEmpty ||
        _selectedDriver == null ||
        _startingPointLocation == null ||
        _endPointLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('routes').add({
        'routeID': _routeID.text,
        'routeName': _routeName.text,
        'busNumber': _busID.text,
        'startingPoint': {
          'latitude': _startingPointLocation!.latitude,
          'longitude': _startingPointLocation!.longitude,
        },
        'endPoint': {
          'latitude': _endPointLocation!.latitude,
          'longitude': _endPointLocation!.longitude,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus Route added successfully!')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MapAdmin(
                    adminEmail: widget.adminEmail,
                    adminPassword: widget.adminPassword,
                  )));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving route: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bus Route"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _routeID,
                            decoration: InputDecoration(
                              labelText: "Route Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _busID,
                            decoration: InputDecoration(
                              labelText: "Bus Number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedDriver,
                            items: _drivers.map((driver) {
                              return DropdownMenuItem(
                                value: driver,
                                child: Text(driver),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDriver = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Driver Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _startingPoint,
                            readOnly: true,
                            onTap: () => _openMapForLocation(true),
                            decoration: InputDecoration(
                              labelText: "Starting Point",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: const Icon(Icons.map),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _endPoint,
                            readOnly: true,
                            onTap: () => _openMapForLocation(false),
                            decoration: InputDecoration(
                              labelText: "End Point",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: const Icon(Icons.map),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitBusRoutes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
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
    _markers = {
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
        },
      ),
    };
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
          },
        ),
      };
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
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 15.0,
        ),
        onTap: _onMapTapped,
        markers: _markers,
      ),
    );
  }
}
