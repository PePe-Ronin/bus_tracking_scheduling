import 'package:flutter/material.dart';

class addTrips extends StatefulWidget {
  const addTrips({super.key});

  @override
  State<addTrips> createState() => _addTripsState();
}

class _addTripsState extends State<addTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bus Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
            color: Color(0xFF8C82FF),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Color(0xFF4D3CFF),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF4D3CFF),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.directions_bus, color: Colors.white, size: 28),
                SizedBox(height: 8),
                Text(
                  'Bus Trips',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage and track all your scheduled bus journeys',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TripCard(
            date: "March 15, 2024",
            scheduleId: "SCH-2024-001",
            time: "08:30 AM",
            status: "Active",
            statusColor: Colors.teal,
          ),
          const SizedBox(height: 12),
          TripCard(
            date: "March 16, 2024",
            scheduleId: "SCH-2024-002",
            time: "10:15 AM",
            status: "Scheduled",
            statusColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String date;
  final String scheduleId;
  final String time;
  final String status;
  final Color statusColor;

  const TripCard({
    super.key,
    required this.date,
    required this.scheduleId,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    color: Color(0xFF4D3CFF)),
                const SizedBox(width: 8),
                Expanded(child: Container()),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Date", style: TextStyle(color: Colors.black54)),
                const SizedBox(width: 20),
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Schedule ID",
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(width: 8),
                Text(scheduleId,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.black54),
                const SizedBox(width: 8),
                Text("Departure: $time"),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text("View Details"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
