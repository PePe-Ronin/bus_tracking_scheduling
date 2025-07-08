import 'package:flutter/material.dart';

class studentAttendance extends StatefulWidget {
  const studentAttendance({super.key});

  @override
  State<studentAttendance> createState() => _studentAttendanceState();
}

final Color gradientStart = const Color(0xFF4F92FF);
final Color gradientEnd = const Color(0xFF7B42F6);

class _studentAttendanceState extends State<studentAttendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: const Icon(Icons.arrow_back),
        actions: const [
          Icon(Icons.download),
          SizedBox(width: 16),
          Icon(Icons.more_vert),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Attendance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track and manage student attendance for trips',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.group, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip ID'),
                        Text(
                          'TRP-2024-001',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Destination'),
                        Text(
                          'Science Museum',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBCCFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_bus, size: 16),
                        SizedBox(width: 4),
                        Text('Active Trip'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Student List',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                _statusCounter('Present', 24, Colors.teal),
                const SizedBox(width: 10),
                _statusCounter('Absent', 3, Colors.redAccent),
              ],
            ),
            const SizedBox(height: 10),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
            _studentCard('John Smith', 'STU-001', '08:30 AM'),
          ],
        ),
      ),
    );
  }

  Widget _statusCounter(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        '$label: $count',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _studentCard(String name, String id, String timeIn) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Text(
            name.split(' ').map((e) => e[0]).take(2).join(),
            style: const TextStyle(color: Colors.deepPurple),
          ),
        ),
        title: Text(name),
        subtitle: Text('Student ID: $id\nIn: $timeIn'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Present',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
