import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/user_repository.dart';
import '../theme/colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  File? _image;
  bool _removePhoto = false;
  bool _loading = false;
  String? _gender;
  DateTime? _dob;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _user?.displayName ?? '';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    if (!snap.exists || !mounted) return;
    final data = snap.data()!;
    setState(() {
      _phoneCtrl.text = data['phone'] ?? '';
      _cityCtrl.text = data['city'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _gender = data['gender'];
      final ts = data['dob'];
      if (ts is Timestamp) _dob = ts.toDate();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Photo picker ────────────────────────────────────────────────────────────

  Future<void> _showPhotoPicker() async {
    final hasExisting =
        (_image != null || _user?.photoURL != null) && !_removePhoto;
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
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  // ── Date of birth picker ────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 13),
      helpText: 'Date of Birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (_user == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    setState(() => _loading = true);
    try {
      // Handle photo
      String? photoUrl;
      if (_removePhoto) {
        try {
          await FirebaseStorage.instance
              .ref()
              .child('profile_photos/${_user!.uid}.jpg')
              .delete();
        } catch (_) {}
        await _user!.updatePhotoURL(null);
      } else if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos/${_user!.uid}.jpg');
        await ref.putFile(_image!);
        photoUrl = await ref.getDownloadURL();
        await _user!.updatePhotoURL(photoUrl);
      }

      // Update Firebase Auth display name
      await _user!.updateDisplayName(_nameCtrl.text.trim());
      await _user!.reload();

      // Update Firestore profile
      await ref
          .read(userRepositoryProvider)
          .updateProfile(_user!.uid, {
        'name': _nameCtrl.text.trim(),
        'photoUrl': _removePhoto ? null : (photoUrl ?? _user!.photoURL),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'gender': _gender,
        'dob': _dob != null ? Timestamp.fromDate(_dob!) : null,
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      });

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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showInitial = _image == null &&
        (_user?.photoURL == null || _removePhoto);

    ImageProvider? bgImage;
    if (_image != null) {
      bgImage = FileImage(_image!);
    } else if (_user?.photoURL != null && !_removePhoto) {
      bgImage = NetworkImage(_user!.photoURL!);
    }

    final initials = () {
      if (_user?.displayName?.isNotEmpty == true) {
        final p = _user!.displayName!.trim().split(' ');
        return p.length >= 2
            ? '${p[0][0]}${p[1][0]}'.toUpperCase()
            : p[0][0].toUpperCase();
      }
      return (_user?.email ?? 'U')[0].toUpperCase();
    }();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _loading ? null : _saveProfile,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _showPhotoPicker,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primary, width: 2.5),
                        color: AppColors.primaryContainer,
                        image: bgImage != null
                            ? DecorationImage(
                                image: bgImage, fit: BoxFit.cover)
                            : null,
                      ),
                      child: showInitial
                          ? Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
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
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _showPhotoPicker,
                child: const Text('Change Photo'),
              ),
            ),

            const SizedBox(height: 8),

            // ── Basic Info ───────────────────────────────────────────────────
            _SectionHeader('Basic Information'),
            const SizedBox(height: 12),

            _FieldCard(children: [
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1, indent: 52),
              // Phone
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  prefixText: '+91  ',
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Personal Details ─────────────────────────────────────────────
            _SectionHeader('Personal Details'),
            const SizedBox(height: 12),

            // Gender
            _FieldCard(children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wc_rounded,
                            size: 20, color: AppColors.onSurfaceMuted),
                        const SizedBox(width: 14),
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genders.map((g) {
                        final selected = _gender == g;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _gender = selected ? null : g),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.outline,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              g,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Date of Birth
              InkWell(
                onTap: _pickDob,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined,
                          size: 20, color: AppColors.onSurfaceMuted),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dob != null
                                  ? '${_dob!.day} ${_monthName(_dob!.month)} ${_dob!.year}'
                                  : 'Select date of birth',
                              style: TextStyle(
                                fontSize: 14,
                                color: _dob != null
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.onSurfaceMuted, size: 20),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Location & Bio ───────────────────────────────────────────────
            _SectionHeader('Location & Bio'),
            const SizedBox(height: 12),

            _FieldCard(children: [
              TextField(
                controller: _cityCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1, indent: 52),
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.notes_rounded),
                  ),
                  alignLabelWithHint: true,
                  border: InputBorder.none,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Account ──────────────────────────────────────────────────────
            _SectionHeader('Account'),
            const SizedBox(height: 12),

            _FieldCard(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 20, color: AppColors.onSurfaceMuted),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email address',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user?.email ?? '',
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
            ]),

            const SizedBox(height: 32),

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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceMuted,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ── Grouped field card ────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  const _FieldCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ── Bottom sheet photo option ─────────────────────────────────────────────────

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
                color: Color.fromRGBO(color.r.toInt(), color.g.toInt(),
                    color.b.toInt(), 0.1),
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
