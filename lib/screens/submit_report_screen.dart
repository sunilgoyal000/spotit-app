import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final PageController _pageController = PageController();
  int currentStep = 0;

  // DATA
  String category = "Garbage";
  File? image;
  String? locationText;

  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool sharePhone = false;

  final List<_IssueCategory> categories = const [
    _IssueCategory("Garbage", Icons.delete, Colors.green),
    _IssueCategory("Pothole", Icons.construction, Colors.brown),
    _IssueCategory("Water Leakage", Icons.water_drop, Colors.blue),
    _IssueCategory("Streetlight", Icons.lightbulb, Colors.orange),
    _IssueCategory("Other", Icons.more_horiz, Colors.grey),
  ];

  // ─────────────────────────────
  // NAVIGATION
  // ─────────────────────────────
  void next() {
    if (currentStep < 2) {
      setState(() => currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void back() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  // ─────────────────────────────
  // IMAGE
  // ─────────────────────────────
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => image = File(picked.path));
  }

  // ─────────────────────────────
  // LOCATION
  // ─────────────────────────────
  Future<void> getLocation() async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission != PermissionStatus.granted) return;

    final loc = await location.getLocation();
    if (loc.latitude == null || loc.longitude == null) return;

    setState(() {
      locationText = "${loc.latitude}, ${loc.longitude}";
    });
  }

  Future<void> openInMaps() async {
    if (locationText == null) return;
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$locationText",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ─────────────────────────────
  // SUBMIT
  // ─────────────────────────────
  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await StorageService.uploadImage(image!);
      }

      await FirestoreService.submitReport(
        userId: user.uid,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        sharePhone: sharePhone,
        category: category,
        description: descriptionController.text.trim(),
        location: locationText ?? "Not provided",
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  // ─────────────────────────────
  // UI
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report an Issue")),
      body: Column(
        children: [
          _ProgressIndicator(step: currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepCategory(),
                _stepDetails(),
                _stepContact(),
              ],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // STEPS
  // ─────────────────────────────
  Widget _stepCategory() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: categories.map((item) {
          final selected = category == item.label;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => category = item.label),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? item.color.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    selected ? Border.all(color: item.color, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(height: 8),
                  Text(item.label, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stepDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Describe the issue",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text("Get Location"),
            onPressed: getLocation,
          ),
          if (locationText != null)
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("View on map"),
              onPressed: openInMaps,
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Add Photo"),
            onPressed: pickImage,
          ),
          if (image != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image!, height: 180),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepContact() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Your Name"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: "Phone Number"),
            keyboardType: TextInputType.phone,
          ),
          Row(
            children: [
              Checkbox(
                value: sharePhone,
                onChanged: (v) => setState(() => sharePhone = v ?? false),
              ),
              const Text("Share phone with authority"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (currentStep > 0)
            TextButton(onPressed: back, child: const Text("Back")),
          const Spacer(),
          ElevatedButton(
            onPressed: currentStep == 2 ? submit : next,
            child: Text(currentStep == 2 ? "Submit" : "Next"),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────
// PROGRESS BAR
// ─────────────────────────────
class _ProgressIndicator extends StatelessWidget {
  final int step;

  const _ProgressIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (step + 1) / 3,
      minHeight: 6,
    );
  }
}

// ─────────────────────────────
// HELPER MODEL
// ─────────────────────────────
class _IssueCategory {
  final String label;
  final IconData icon;
  final Color color;

  const _IssueCategory(this.label, this.icon, this.color);
}
