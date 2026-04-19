import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD...",
      authDomain: "spotit-3d086.firebaseapp.com",
      projectId: "spotit-3d086",
      storageBucket: "spotit-3d086.firebasestorage.app",
      messagingSenderId: "210163450744",
      appId: "1:210163450744:web:35230514ce8319c8283e8d",
    ),
  );
  runApp(const SpotItAdmin());
}

class SpotItAdmin extends StatelessWidget {
  const SpotItAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotIt Admin',
      theme: ThemeData(useMaterial3: true),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedDistrict = 'All';
  String selectedStatus = 'All';
  DateTimeRange? dateRange;

  final districts = ['All', 'Mohali', 'Chandigarh', 'Patiala', 'Ludhiana'];
  final statuses = ['All', 'pending', 'in-progress', 'resolved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotIt Admin Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _exportCSV),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                    items: districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedDistrict = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: statuses
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.capitalize()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedStatus = value!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _reportsList()),
        ],
      ),
    );
  }

  Widget _reportsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading reports'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports =
            snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final matchesDistrict =
                  selectedDistrict == 'All' ||
                  data['district'] == selectedDistrict;
              final matchesStatus =
                  selectedStatus == 'All' || data['status'] == selectedStatus;
              return matchesDistrict && matchesStatus;
            }).toList() ??
            [];
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text('${data['category']} - ${data['location']}'),
                subtitle: Text(data['description']),
                trailing: DropdownButton<String>(
                  value: data['status'],
                  items: ['pending', 'in-progress', 'resolved', 'rejected']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.capitalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (newStatus) => FirebaseFirestore.instance
                      .collection('reports')
                      .doc(doc.id)
                      .update({'status': newStatus}),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _exportCSV() {
    // Implementation
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
