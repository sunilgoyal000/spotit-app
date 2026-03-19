import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/status_timeline.dart';

class ReportDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final data = report.data() as Map<String, dynamic>;
    final String location = data['location'] ?? "";
    final String status = data['status'] ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷 Category
            Text(
              data['category'] ?? "No Category",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 🔖 Status Chip
            _statusChip(status),

            const SizedBox(height: 16),

            // 🔄 Status Timeline
            const Text(
              "Progress",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StatusTimeline(status: status),

            const Divider(height: 32),

            // 📝 Description
            _cardSection(
              title: "Description",
              value: data['description'] ?? "No description",
            ),

            // 📍 Location
            _cardSection(
              title: "Location",
              value: location.isNotEmpty ? location : "Not provided",
            ),

            // 🌍 Open Map Button
            if (location.contains(','))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text("Open in Google Maps"),
                  onPressed: () => _openMap(location),
                ),
              ),

            // 🖼 Image
            if (data['imageUrl'] != null &&
                data['imageUrl'].toString().isNotEmpty)
              _imageSection(data['imageUrl']),

            const SizedBox(height: 16),

            // 🕒 Created At
            _cardSection(
              title: "Created At",
              value: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                  : "Unknown",
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 Status Chip
  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'resolved':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }

  // 📦 Card Section
  Widget _cardSection({required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }

  // 🖼 Image Section
  Widget _imageSection(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Image", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ],
    );
  }

  // 🌍 Open Google Maps
  Future<void> _openMap(String location) async {
    final parts = location.split(',');
    if (parts.length != 2) return;

    final lat = parts[0].trim();
    final lng = parts[1].trim();

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
