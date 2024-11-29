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

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

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
      // Fetch all documents from the 'drivers' collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

      // Combine firstName, middleName, and lastName for each driver
      List<String> fetchedDrivers = snapshot.docs.map((doc) {
        String firstName = doc['firstName'] ?? '';
        String middleName = doc['middleName'] ?? '';
        String lastName = doc['lastName'] ?? '';

        // Concatenate names with spaces
        return '$firstName $middleName $lastName'.trim();
      }).toList();

      // Update the state with the fetched driver names
      setState(() {
        _drivers = fetchedDrivers;
        _isLoading = false;
      });
    } catch (e) {
      // Handle any errors
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching drivers: $e')),
      );
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _openMapForLocation(bool isStartingPoint) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: isStartingPoint
              ? _startingPointLocation ?? const LatLng(37.7749, -122.4194)
              : _endPointLocation ?? const LatLng(37.7749, -122.4194),
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
        _endPointLocation == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('bus_schedules').add({
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
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus schedule added successfully!')),
      );
      Navigator.pop(context); // Go back after successful submission
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
                  // Route Information Section
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
                  // Location Picker Section
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
                  const SizedBox(height: 16),
                  // Schedule Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text("Start Time"),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _pickTime(context, true),
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    _startTime == null
                                        ? "Select Time"
                                        : _startTime!.format(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text("End Time"),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _pickTime(context, false),
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    _endTime == null
                                        ? "Select Time"
                                        : _endTime!.format(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitBusSchedule,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
    );
  }
}

class MapPickerScreen extends StatelessWidget {
  final LatLng initialLocation;

  const MapPickerScreen({required this.initialLocation, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: initialLocation,
            draggable: true,
            onDragEnd: (newPosition) {
              Navigator.pop(context, newPosition);
            },
          ),
        },
      ),
    );
  }
}
