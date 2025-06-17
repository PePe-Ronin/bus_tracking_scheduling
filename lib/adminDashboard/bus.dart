import 'package:bus/adminDashboard/addbus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class busScreen extends StatelessWidget {
  final String adminEmail;
  final String adminPassword;
  const busScreen(
      {super.key, required this.adminEmail, required this.adminPassword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Buses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Bus'),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('bus').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No buses found.'),
                    );
                  }

                  final drivers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      final busID = driver['busID'];
                      final plateNumber = driver['plateNumber'];
                      final capacity = driver['capacity'];
                      final name = driver['driver'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DriverCard(
                          busID: busID,
                          plateNumber: plateNumber,
                          capacity: capacity,
                          name: name,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const addBus(
                  //       adminEmail: widget.adminEmail,
                  //       adminPassword: widget.adminPassword,
                  //     ),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                child: const Text(
                  'Add Bus',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class DriverCard extends StatelessWidget {
  final String busID;
  final String plateNumber;
  final String capacity;
  final String name;

  const DriverCard({
    super.key,
    required this.busID,
    required this.plateNumber,
    required this.capacity,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bus Number: $busID',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Plate Number: $plateNumber',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              'Capacity: $capacity',
            ),
            const SizedBox(height: 4),
            Text(
              'Driver: $name',
            ),
          ],
        ),
      ),
    );
  }
}
