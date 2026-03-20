import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final nameCtrl = TextEditingController();
  File? image;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl.text = user?.displayName ?? "";
  }

  // 📷 Pick image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  // 💾 Save profile
  Future<void> saveProfile() async {
    if (user == null) return;

    setState(() => loading = true);

    try {
      String? photoUrl;

      // Upload image if selected
      if (image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("profile_photos")
            .child("${user!.uid}.jpg");

        await ref.putFile(image!);
        photoUrl = await ref.getDownloadURL();
      }

      // Update auth profile
      await user!.updateDisplayName(nameCtrl.text.trim());
      if (photoUrl != null) {
        await user!.updatePhotoURL(photoUrl);
      }

      await user!.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Avatar
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: image != null
                    ? FileImage(image!)
                    : (user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null) as ImageProvider?,
                child: image == null && user?.photoURL == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            // 🧾 Name
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Your Name",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const Spacer(),

            // 💾 Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
