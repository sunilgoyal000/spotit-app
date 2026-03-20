import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/category_chip.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  int currentStep = 0;
  bool isSubmitting = false;

  String category = "Garbage";
  String? _selectedDistrict = 'Mohali';
  File? image;
  String? locationText;
  bool sharePhone = false;

  String get _trimmedName => nameController.text.trim();
  String get _trimmedDescription => descriptionController.text.trim();

  final List<String> districts = [
    'Mohali',
    'Chandigarh',
    'Patiala',
    'Ludhiana',
  ];

  final List<_IssueCategory> categories = const [
    _IssueCategory("Garbage", Icons.delete, Colors.green),
    _IssueCategory("Pothole", Icons.construction, Colors.brown),
    _IssueCategory("Water Leakage", Icons.water_drop, Colors.blue),
    _IssueCategory("Streetlight", Icons.lightbulb, Colors.orange),
    _IssueCategory("Other", Icons.more_horiz, Colors.grey),
  ];

  final List<_StepContent> steps = const [
    _StepContent(
      title: "Choose issue type",
      subtitle: "Pick the category that best matches what you want to report.",
    ),
    _StepContent(
      title: "Add details",
      subtitle: "Describe the issue clearly and attach evidence if possible.",
    ),
    _StepContent(
      title: "Contact & review",
      subtitle: "Confirm your details before sending the report.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    descriptionController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (!_validateCurrentStep()) return;

    if (currentStep < steps.length - 1) {
      setState(() => currentStep++);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> back() async {
    if (currentStep > 0) {
      if (!mounted) return;
      setState(() => currentStep--);
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  bool _validateCurrentStep() {
    if (currentStep == 0) {
      return true;
    }

    if (currentStep == 1) {
      if (descriptionController.text.trim().length < 10) {
        _showMessage("Add at least 10 characters describing the issue.");
        return false;
      }

      if (locationText == null) {
        _showMessage("Please capture your location before continuing.");
        return false;
      }
    }

    if (currentStep == 2) {
      if (nameController.text.trim().isEmpty) {
        _showMessage("Please enter your name.");
        return false;
      }

      if (_selectedDistrict == null || _selectedDistrict!.isEmpty) {
        _showMessage("Please select your district.");
        return false;
      }
    }

    return true;
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Take a photo"),
                subtitle: const Text("Capture the issue right now"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                subtitle: const Text("Use a photo you already have"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getLocation() async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        _showMessage("Location services need to be enabled to continue.");
        return;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

    if (permission != PermissionStatus.granted) {
      _showMessage("Location permission is required to submit a report.");
      return;
    }

    final loc = await location.getLocation();
    if (loc.latitude == null || loc.longitude == null) {
      _showMessage("We couldn't fetch your location. Please try again.");
      return;
    }

    if (!mounted) return;
    setState(() {
      locationText = "${loc.latitude}, ${loc.longitude}";
    });
  }

  Future<void> openInMaps() async {
    if (locationText == null) return;

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$locationText",
    );
    if (!await canLaunchUrl(uri)) {
      _showMessage("Couldn't open the map preview on this device.");
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> submit() async {
    if (!_validateCurrentStep()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage("Please log in again before submitting.");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await StorageService.uploadImage(image!);
      }

      final locParts = locationText!.split(', ');
      final lat = double.tryParse(locParts[0]) ?? 0.0;
      final lng =
          double.tryParse(locParts.length > 1 ? locParts[1] : '0') ?? 0.0;

      await FirestoreService.submitReport(
        userId: user.uid,
        name: _trimmedName,
        phone: phoneController.text.trim(),
        sharePhone: sharePhone,
        category: category,
        description: _trimmedDescription,
        location: locationText!,
        lat: lat,
        lng: lng,
        district: _selectedDistrict ?? 'Mohali',
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Report submitted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage("Failed to submit report. Please try again.");
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  _IssueCategory get _selectedCategory {
    return categories.firstWhere((item) => item.label == category);
  }

  String get _locationLabel {
    if (locationText == null) return "Location not captured yet";
    final parts = locationText!.split(', ');
    if (parts.length < 2) return locationText!;
    return "Lat ${parts[0]}, Lng ${parts[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];

    return Scaffold(
      appBar: AppBar(title: const Text("Report an Issue")),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(
              currentStep: currentStep,
              steps: steps,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _stepCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryBanner(
            icon: Icons.tips_and_updates_outlined,
            title: "Tip",
            message:
                "Choose the closest category so the report reaches the right team faster.",
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.25,
              children: categories
                  .map(
                    (item) => CategoryChip(
                      label: item.label,
                      icon: item.icon,
                      color: item.color,
                      isSelected: category == item.label,
                      onTap: () => setState(() => category = item.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDetails() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _SummaryBanner(
          icon: _selectedCategory.icon,
          title: "Selected category",
          message: category,
          iconColor: _selectedCategory.color,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Describe the issue *",
            hintText:
                "Mention landmarks, severity, and anything authorities should know.",
            helperText: "Write at least 10 characters.",
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      locationText == null
                          ? Icons.location_searching
                          : Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Location",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _locationLabel,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        locationText == null
                            ? "Capture location"
                            : "Refresh location",
                      ),
                      onPressed: getLocation,
                    ),
                    if (locationText != null)
                      TextButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text("Preview on map"),
                        onPressed: openInMaps,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Photo evidence",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Add a clear photo if possible. It helps authorities verify the issue faster.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(image == null ? "Add photo" : "Replace photo"),
                  onPressed: showImageSourcePicker,
                ),
                if (image != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepContact() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: "Your Name *",
            hintText: "Enter the name authorities can reference",
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: const InputDecoration(
            labelText: "District *",
          ),
          items: districts
              .map(
                (district) => DropdownMenuItem(
                  value: district,
                  child: Text(district),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedDistrict = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone Number",
            hintText: "Optional",
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: sharePhone,
          onChanged: (v) => setState(() => sharePhone = v ?? false),
          title: const Text("Share phone with authority"),
          subtitle: const Text(
            "Only enable this if you'd like authorities to contact you directly.",
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Review before you submit",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _ReviewRow(label: "Issue type", value: category),
                _ReviewRow(
                  label: "Description",
                  value: descriptionController.text.trim().isEmpty
                      ? "Not added yet"
                      : descriptionController.text.trim(),
                ),
                _ReviewRow(label: "Location", value: _locationLabel),
                _ReviewRow(
                  label: "Photo",
                  value: image == null ? "No photo attached" : "Photo attached",
                ),
                _ReviewRow(
                  label: "District",
                  value: _selectedDistrict ?? "Not selected",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            if (currentStep > 0)
              TextButton(
                onPressed: isSubmitting ? null : back,
                child: const Text("Back"),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : (currentStep == steps.length - 1 ? submit : next),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(currentStep == steps.length - 1
                      ? "Submit report"
                      : "Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  final List<_StepContent> steps;

  const _ProgressHeader({
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index == currentStep;
              final isComplete = index < currentStep;

              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == steps.length - 1 ? 0 : 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isActive || isComplete
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant,
                            child: Text(
                              "${index + 1}",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isActive || isComplete
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              steps[index].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive || isComplete
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? iconColor;

  const _SummaryBanner({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCategory {
  final String label;
  final IconData icon;
  final Color color;

  const _IssueCategory(this.label, this.icon, this.color);
}

class _StepContent {
  final String title;
  final String subtitle;

  const _StepContent({
    required this.title,
    required this.subtitle,
  });
}
