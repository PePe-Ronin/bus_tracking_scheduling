import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ParentRegistrations extends StatelessWidget {
  const ParentRegistrations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Registration'),
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
                    .collection('parents')
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: RegistrationCard(
                          name: name,
                          status: 'Pending',
                          onApprove: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(student.id)
                                  .set({
                                ...student.data() as Map<String, dynamic>,
                                'userType': 'Parent',
                                'approvedDate': FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance
                                  .collection('parents')
                                  .doc(student.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Parent approved successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error approving parent: $e')),
                              );
                            }
                          },
                          onReject: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Parent rejected.')),
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
                    .where('userType', isEqualTo: 'Parent')
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
                      final approvedDate =
                          (user['approvedDate'] as Timestamp?)?.toDate();
                      final formattedApprovedDate = approvedDate != null
                          ? "${approvedDate.year}-${approvedDate.month.toString().padLeft(2, '0')}-${approvedDate.day.toString().padLeft(2, '0')}"
                          : "Unknown";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ApprovedCard(
                          name: name,
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

  const SectionTitle({super.key, required this.title});

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
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RegistrationCard({
    super.key,
    required this.name,
    required this.status,
    required this.onApprove,
    required this.onReject,
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
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
  final String approvedDate;

  const ApprovedCard({
    super.key,
    required this.name,
    required this.approvedDate,
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
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Approved',
                  style: TextStyle(color: Colors.green, fontSize: 14),
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
