import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../components/stat_card.dart';
import 'submit_report_screen.dart';
import 'my_reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SpotIt"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Greeting
              Text(
                "Welcome 👋",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (user?.email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    user!.email!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 24),

              // 📊 Stats - Responsive Grid
              if (user != null)
                StreamBuilder<Map<String, int>>(
                  stream: FirestoreService.reportStats(user.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final stats = snapshot.data!;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossCount = constraints.maxWidth > 400 ? 3 : 2;
                        return GridView.count(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2,
                          children: [
                            StatCard(
                              title: "Total",
                              value: stats['total']!,
                              icon: Icons.description,
                              color: Colors.blue,
                            ),
                            StatCard(
                              title: "Pending",
                              value: stats['pending']!,
                              icon: Icons.hourglass_top,
                              color: Colors.orange,
                            ),
                            StatCard(
                              title: "Resolved",
                              value: stats['resolved']!,
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 28),

              // ⚡ Section title
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // 🚨 Report Issue
              _ActionTile(
                icon: Icons.report_problem,
                color: Colors.orange,
                title: "Report an Issue",
                subtitle: "Garbage, potholes, water leakage & more",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubmitReportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 📂 My Reports
              _ActionTile(
                icon: Icons.history,
                color: Colors.blue,
                title: "My Reports",
                subtitle: "Track status of submitted issues",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyReportsScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // 🏷 Footer
              const Center(
                child: Text(
                  "SpotIt • Making cities better",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔘 Action Tile (cleaner than cards)
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
