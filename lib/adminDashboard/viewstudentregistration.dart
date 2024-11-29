import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentRegistration extends StatelessWidget {
  const StudentRegistration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Pending Registrations'),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No pending registrations found.'),
                    );
                  }

                  final students = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final name =
                          "${student['firstName']} ${student['middleName']} ${student['lastName']}";
                      final grade =
                          "${student['gradeLevel']} - ${student['strand']}";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: RegistrationCard(
                          name: name,
                          grade: grade,
                          status: 'Pending',
                          onApprove: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(student.id)
                                  .set({
                                ...student.data() as Map<String, dynamic>,
                                'userType': 'Student',
                                'approvedDate': FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance
                                  .collection('students')
                                  .doc(student.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Student approved successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error approving student: $e')),
                              );
                            }
                          },
                          onReject: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Student rejected.')),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Approved Registrations'),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('userType', isEqualTo: 'Student')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No approved registrations found.'),
                    );
                  }

                  final approvedUsers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: approvedUsers.length,
                    itemBuilder: (context, index) {
                      final user = approvedUsers[index];
                      final name =
                          "${user['firstName']} ${user['middleName']} ${user['lastName']}";
                      final grade = "${user['gradeLevel']} - ${user['strand']}";
                      final approvedDate =
                          (user['approvedDate'] as Timestamp?)?.toDate();
                      final formattedApprovedDate = approvedDate != null
                          ? "${approvedDate.year}-${approvedDate.month.toString().padLeft(2, '0')}-${approvedDate.day.toString().padLeft(2, '0')}"
                          : "Unknown";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ApprovedCard(
                          name: name,
                          grade: grade,
                          approvedDate: formattedApprovedDate,
                        ),
                      );
                    },
                  );
                },
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

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class RegistrationCard extends StatelessWidget {
  final String name;
  final String grade;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RegistrationCard({
    Key? key,
    required this.name,
    required this.grade,
    required this.status,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

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
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(grade, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: const TextStyle(color: Colors.orange, fontSize: 14),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApprovedCard extends StatelessWidget {
  final String name;
  final String grade;
  final String approvedDate;

  const ApprovedCard({
    Key? key,
    required this.name,
    required this.grade,
    required this.approvedDate,
  }) : super(key: key);

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
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(grade, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Approved',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
                Text(
                  'Approved on: $approvedDate',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
