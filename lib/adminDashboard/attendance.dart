import 'package:flutter/material.dart';

class studentAttendance extends StatefulWidget {
  const studentAttendance({super.key});

  @override
  State<studentAttendance> createState() => _studentAttendanceState();
}

final Color gradientStart = Color(0xFF4F92FF);
final Color gradientEnd = Color(0xFF7B42F6);

class _studentAttendanceState extends State<studentAttendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        leading: Icon(Icons.arrow_back),
        actions: [
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
              padding: EdgeInsets.all(16),
              child: Row(
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
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
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
                  Expanded(
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFDBCCFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
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
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name or ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Student List',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Spacer(),
                _statusCounter('Present', 24, Colors.teal),
                SizedBox(width: 10),
                _statusCounter('Absent', 3, Colors.redAccent),
              ],
            ),
            SizedBox(height: 10),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        '$label: $count',
        style: TextStyle(color: Colors.white),
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
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        title: Text(name),
        subtitle: Text('Student ID: $id\nIn: $timeIn'),
        isThreeLine: true,
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Present',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
