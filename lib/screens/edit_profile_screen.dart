import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

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
    nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => image = File(picked.path));
  }

  Future<void> saveProfile() async {
    if (user == null) return;
    if (nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    setState(() => loading = true);
    try {
      String? photoUrl;
      if (image != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_photos/${user!.uid}.jpg');
        await ref.putFile(image!);
        photoUrl = await ref.getDownloadURL();
      }

      await user!.updateDisplayName(nameCtrl.text.trim());
      if (photoUrl != null) await user!.updatePhotoURL(photoUrl);
      await user!.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update profile. Try again.');
    }
    setState(() => loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = image != null || user?.photoURL != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Avatar picker ───────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                        boxShadow: AppColors.cardShadow,
                        color: AppColors.primaryContainer,
                        image: image != null
                            ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
                            : (user?.photoURL != null
                                ? DecorationImage(image: NetworkImage(user!.photoURL!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: !hasPhoto
                          ? Center(
                              child: Text(
                                (user?.email ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Edit badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: pickImage,
              child: const Text('Change Photo'),
            ),

            const SizedBox(height: 24),

            // ── Name field ───────────────────────────────────────────────
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: 12),

            // Email (read-only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.onSurfaceMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email address',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceMuted, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
