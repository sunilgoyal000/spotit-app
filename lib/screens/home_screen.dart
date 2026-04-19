import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/report_repository.dart';
import '../components/stat_card.dart';
import '../theme/colors.dart';
import 'submit_report_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(user: user, greeting: _greeting(), initials: user != null ? _initials(user) : 'U'),
          ),

          // ── Stats ─────────────────────────────────────────────────────
          if (user != null)
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final statsAsync = ref.watch(reportStatsProvider(user.uid));
                  final stats = statsAsync.value ?? {'total': 0, 'pending': 0, 'resolved': 0};
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total',
                            value: stats['total']!,
                            icon: Icons.assignment_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pending',
                            value: stats['pending']!,
                            icon: Icons.hourglass_top_rounded,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Resolved',
                            value: stats['resolved']!,
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats — isolated StreamBuilder widget
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StatsRow(uid: user.uid),
              ),

            const SizedBox(height: 28),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_city_rounded,
                      iconColor: AppColors.secondary,
                      title: 'City Coverage',
                      subtitle: 'Mohali, Chandigarh\n& more',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.verified_rounded,
                      iconColor: AppColors.success,
                      title: 'Verified Reports',
                      subtitle: 'Reviewed by local\nauthorities',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Center(
              child: Text(
                'SpotIt • Making cities better',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 96), // space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Stats Row — isolated widget so StreamBuilder rebuilds only this ──────────

class _StatsRow extends StatelessWidget {
  final String uid;
  const _StatsRow({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: FirestoreService.reportStats(uid),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'total': 0, 'pending': 0, 'resolved': 0};
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total',
                value: stats['total']!,
                icon: Icons.assignment_rounded,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Pending',
                value: stats['pending']!,
                icon: Icons.hourglass_top_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Resolved',
                value: stats['resolved']!,
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final User? user;
  final VoidCallback? onProfileTap;
  const _HeroHeader({required this.user, this.onProfileTap});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _initials() {
    final u = user;
    if (u == null) return 'U';
    if (u.displayName?.isNotEmpty == true) {
      final p = u.displayName!.trim().split(' ');
      return p.length >= 2
          ? '${p[0][0]}${p[1][0]}'.toUpperCase()
          : p[0][0].toUpperCase();
    }
    return (u.email ?? 'U')[0].toUpperCase();
  }

  String _displayName() {
    final u = user;
    if (u == null) return 'there';
    if (u.displayName?.isNotEmpty == true) {
      return u.displayName!.split(' ').first;
    }
    return u.email?.split('@').first ?? 'there';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xB3FFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayName(),
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar — taps to Profile tab
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x33FFFFFF),
                    border: Border.all(color: const Color(0x66FFFFFF), width: 2),
                    image: user?.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(user!.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.photoURL == null
                      ? Center(
                          child: Text(
                            _initials(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _TaglinePill(),
        ],
      ),
    );
  }
}

class _TaglinePill extends StatelessWidget {
  const _TaglinePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'Report civic issues in your area',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                iconColor.r.toInt(),
                iconColor.g.toInt(),
                iconColor.b.toInt(),
                0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
