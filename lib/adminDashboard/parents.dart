import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _SettingsState();
}

class _SettingsState extends State<ParentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parents'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userType', isEqualTo: 'Parent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No parents found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var studentData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Combine firstName, middleName, and lastName
              String fullName = [
                studentData['firstName'],
                studentData['middleName'],
                studentData['lastName']
              ].where((name) => name != null && name.isNotEmpty).join(' ');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(fullName.isNotEmpty ? fullName : 'No name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${studentData['email'] ?? 'No email'}'),
                      Text(
                          'Contact Number: ${studentData['ContactNo'] ?? 'No contact number'}'),
                      Text('Strand: ${studentData['strand'] ?? 'No strand'}'),
                      Text(
                          'Grade Level: ${studentData['gradeLevel'] ?? 'No grade level'}'),
                      Text(
                          'Section: ${studentData['section'] ?? 'No section'}'),
                      Text(
                          'Parent Name: ${studentData['parentName'] ?? 'No parent name'}'),
                      Text(
                          'Parent Contact: ${studentData['parentContact'] ?? 'No parent contact'}'),
                      Text(
                          'Location (Lat, Lng): ${studentData['studentLatLNG'] ?? 'No location'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
