import 'package:bus/adminDashboard/adminDashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusScheduler extends StatefulWidget {
  const BusScheduler({super.key});

  @override
  State<BusScheduler> createState() => _BusSchedulerState();
}

class _BusSchedulerState extends State<BusScheduler> {
  String? _selectedDriver;
  List<String> _drivers = [];
  bool _isLoading = true;

  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _startingPointController =
      TextEditingController();
  final TextEditingController _endPointController = TextEditingController();

  LatLng? _startingPointLocation;
  LatLng? _endPointLocation;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

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
          _startingPointController.text =
              '${selectedLocation.latitude}, ${selectedLocation.longitude}';
        } else {
          _endPointLocation = selectedLocation;
          _endPointController.text =
              '${selectedLocation.latitude}, ${selectedLocation.longitude}';
        }
      });
    }
  }

  Future<void> _submitBusSchedule() async {
    if (_routeNameController.text.isEmpty ||
        _busNumberController.text.isEmpty ||
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
        'routeName': _routeNameController.text,
        'busNumber': _busNumberController.text,
        'driver': _selectedDriver,
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
        const SnackBar(content: Text('Bus schedule added successfully!')),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MapAdmin()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving schedule: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bus Schedule"),
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
                            controller: _routeNameController,
                            decoration: InputDecoration(
                              labelText: "Route Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _busNumberController,
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
                            controller: _startingPointController,
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
                            controller: _endPointController,
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
                    onPressed: _submitBusSchedule,
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
