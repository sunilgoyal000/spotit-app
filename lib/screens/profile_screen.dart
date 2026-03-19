import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final email = user.email ?? "No email";
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : "password";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                email.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📧 Email
            Text(
              email,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // 🔐 Provider
            Text(
              "Signed in via ${provider == 'password' ? 'Email & Password' : provider}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // 🧾 Info Card
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Account Information"),
                subtitle: const Text("Manage your account details"),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text("Security"),
                subtitle: const Text("Password & authentication"),
              ),
            ),

            const Spacer(),

            // 🚪 Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
