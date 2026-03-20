import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../components/report_card.dart';
import '../services/firestore_service.dart';
import 'report_details_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  Color _getCategoryColor(String? category) {
    return switch (category) {
      'Garbage' => Colors.green,
      'Pothole' => Colors.brown,
      'Water Leakage' => Colors.blue,
      'Streetlight' => Colors.orange,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please login again")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Reports")),
      body: RefreshIndicator(
        onRefresh: () => Future.value(),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.myReports(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Container()),
                        title: Container(height: 12, color: Colors.white),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 8, color: Colors.white),
                            Container(height: 8, color: Colors.white),
                          ],
                        ),
                        trailing: Container(
                            width: 60, height: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text("Error loading reports"),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final reports = snapshot.data?.docs ?? [];

            if (reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      "No reports submitted yet",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap 'Report an Issue' to get started",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final doc = reports[index];
                final data = doc.data() as Map<String, dynamic>;
                final categoryColor = _getCategoryColor(data['category']);

                return ReportCard(
                  category: data['category'] ?? 'Unknown',
                  location: data['location'] ?? 'No location',
                  description: data['description'] ?? 'No description',
                  status: data['status'] ?? 'pending',
                  imageUrl: data['imageUrl'],
                  categoryColor: categoryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(report: doc),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
