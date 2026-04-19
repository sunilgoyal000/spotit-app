import 'dart:html' as html;

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
  String selectedCategory = 'All';
  DateTimeRange? dateRange;
  Set<String> selectedReports = {};

  final districts = ['All', 'Mohali', 'Chandigarh', 'Patiala', 'Ludhiana'];
  final statuses = ['All', 'pending', 'in-progress', 'resolved', 'rejected'];
  final categories = ['All', 'Garbage', 'Pothole', 'Water Leakage', 'Streetlight'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotIt Admin Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (selectedReports.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: DropdownButton<String>(
                hint: const Text('Bulk Update', style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.green[800],
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                underline: const SizedBox(),
                items: ['pending', 'in-progress', 'resolved', 'rejected']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.capitalize())))
                    .toList(),
                onChanged: _bulkUpdateStatus,
              ),
            ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategory = value!),
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
              final matchesCategory = selectedCategory == 'All' ||
                  data['category']?.toString().toLowerCase() ==
                      selectedCategory.toLowerCase();
              return matchesDistrict && matchesStatus && matchesCategory;
            }).toList() ??
            [];
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: Checkbox(
                  value: selectedReports.contains(doc.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedReports.add(doc.id);
                      } else {
                        selectedReports.remove(doc.id);
                      }
                    });
                  },
                ),
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

  void _bulkUpdateStatus(String? newStatus) {
    if (newStatus == null || selectedReports.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final id in selectedReports) {
      final docRef = FirebaseFirestore.instance.collection('reports').doc(id);
      batch.update(docRef, {'status': newStatus});
    }

    batch.commit().then((_) {
      if (!mounted) return;
      setState(() {
        selectedReports.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated to $newStatus successfully')),
      );
    });
  }

  Future<void> _exportCSV() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    final reports = querySnapshot.docs.where((doc) {
      final data = doc.data();
      final matchesDistrict =
          selectedDistrict == 'All' || data['district'] == selectedDistrict;
      final matchesStatus =
          selectedStatus == 'All' || data['status'] == selectedStatus;
      final matchesCategory = selectedCategory == 'All' ||
          data['category']?.toString().toLowerCase() ==
              selectedCategory.toLowerCase();
      return matchesDistrict && matchesStatus && matchesCategory;
    }).toList();

    if (reports.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reports to export')),
        );
      }
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Category,District,Location,Status,Description,CreatedAt');

    for (var doc in reports) {
      final data = doc.data();
      final category = (data['category'] ?? '').toString().replaceAll(',', ' ');
      final district = (data['district'] ?? '').toString().replaceAll(',', ' ');
      final location = (data['location'] ?? '').toString().replaceAll(',', ' ');
      final status = (data['status'] ?? '').toString();
      final description =
          (data['description'] ?? '').toString().replaceAll('\n', ' ').replaceAll(',', ' ');

      String createdAt = '';
      if (data['createdAt'] != null) {
        createdAt = (data['createdAt'] as Timestamp).toDate().toString();
      }

      buffer.writeln(
          '$category,$district,$location,$status,$description,$createdAt');
    }

    final bytes = buffer.toString().codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'spotit_reports.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
