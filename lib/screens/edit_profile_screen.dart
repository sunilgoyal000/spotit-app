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
  final _nameCtrl = TextEditingController();
  File? _image;
  bool _removePhoto = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Photo picker bottom sheet ─────────────────────────────────────────────

  Future<void> _showPhotoPicker() async {
    final hasExisting = (_image != null || user?.photoURL != null) && !_removePhoto;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _PhotoOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () async {
                  Navigator.pop(context);
                  await _pick(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              _PhotoOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                onTap: () async {
                  Navigator.pop(context);
                  await _pick(ImageSource.camera);
                },
              ),
              if (hasExisting) ...[
                const SizedBox(height: 8),
                _PhotoOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _image = null;
                      _removePhoto = true;
                    });
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (user == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    setState(() => _loading = true);
    try {
      String? photoUrl;

      if (_removePhoto) {
        // Delete from Storage and clear URL
        try {
          await FirebaseStorage.instance
              .ref()
              .child('profile_photos/${user!.uid}.jpg')
              .delete();
        } catch (_) {}
        await user!.updatePhotoURL(null);
      } else if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos/${user!.uid}.jpg');
        await ref.putFile(_image!);
        photoUrl = await ref.getDownloadURL();
        await user!.updatePhotoURL(photoUrl);
      }

      await user!.updateDisplayName(_nameCtrl.text.trim());
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
    if (mounted) setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showInitial = _image == null &&
        (user?.photoURL == null || _removePhoto);

    ImageProvider? bgImage;
    if (_image != null) {
      bgImage = FileImage(_image!);
    } else if (user?.photoURL != null && !_removePhoto) {
      bgImage = NetworkImage(user!.photoURL!);
    }

    final initials = () {
      if (user?.displayName?.isNotEmpty == true) {
        final p = user!.displayName!.trim().split(' ');
        return p.length >= 2
            ? '${p[0][0]}${p[1][0]}'.toUpperCase()
            : p[0][0].toUpperCase();
      }
      return (user?.email ?? 'U')[0].toUpperCase();
    }();

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

            // ── Avatar picker ──────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _showPhotoPicker,
                child: Stack(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                        color: AppColors.primaryContainer,
                        image: bgImage != null
                            ? DecorationImage(image: bgImage, fit: BoxFit.cover)
                            : null,
                      ),
                      child: showInitial
                          ? Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    // Camera badge
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _showPhotoPicker,
              child: const Text('Change Photo'),
            ),

            const SizedBox(height: 24),

            // ── Name field ─────────────────────────────────────────────────
            TextField(
              controller: _nameCtrl,
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
                  const Icon(Icons.email_outlined,
                      color: AppColors.onSurfaceMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email address',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceMuted,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.onSurfaceMuted, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Save button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
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

// ── Bottom sheet option row ────────────────────────────────────────────────────

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                    color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
