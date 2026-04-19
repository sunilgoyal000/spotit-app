import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/report_repository.dart';
import '../components/stat_card.dart';
import '../theme/colors.dart';
import 'submit_report_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: _HeroHeader(
                  user: user, onProfileTap: widget.onProfileTap),
            ),

            const SizedBox(height: 20),

            // ── Stats ──────────────────────────────────────────────────────
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StatsRow(uid: user.uid),
              ),

            const SizedBox(height: 28),

            // ── Categories ─────────────────────────────────────────────────
            const _SectionTitle(
              label: 'Issue Categories',
              subtitle: 'Tap + to report any of these',
            ),
            const SizedBox(height: 14),
            const _CategoriesRow(),

            const SizedBox(height: 28),

            // ── How It Works ───────────────────────────────────────────────
            const _SectionTitle(label: 'How SpotIt Works'),
            const SizedBox(height: 14),
            const _HowItWorksRow(),

            const SizedBox(height: 28),

            // ── City Coverage ──────────────────────────────────────────────
            const _SectionTitle(label: 'City Coverage'),
            const SizedBox(height: 14),
            const _CityRow(),

            const SizedBox(height: 20),

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

            const SizedBox(height: 96),
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
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  final String? subtitle;
  const _SectionTitle({required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  final String uid;
  const _StatsRow({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reportStatsProvider(uid));
    final stats =
        statsAsync.value ?? {'total': 0, 'pending': 0, 'resolved': 0};
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
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: stats['pending']!,
            icon: Icons.hourglass_top_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
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
  }
}

// ── Categories Row ────────────────────────────────────────────────────────────

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  static const _items = [
    (Icons.delete_outline_rounded, 'Garbage', AppColors.garbage),
    (Icons.construction_rounded, 'Pothole', AppColors.pothole),
    (Icons.water_drop_outlined, 'Water\nLeakage', AppColors.waterLeakage),
    (Icons.lightbulb_outline_rounded, 'Street\nLight', AppColors.streetlight),
    (Icons.more_horiz_rounded, 'Other', AppColors.other),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (icon, label, color) = _items[i];
          return _CategoryTile(icon: icon, label: label, color: color);
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryTile(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                  color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── How It Works ──────────────────────────────────────────────────────────────

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow();

  static const _steps = [
    (Icons.camera_alt_rounded, 'Spot It', 'Take a photo of the issue'),
    (Icons.send_rounded, 'Report It', 'Submit with location details'),
    (Icons.verified_rounded, 'Fix It', 'Authorities resolve the issue'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            Expanded(
              child: _StepCard(
                icon: _steps[i].$1,
                title: _steps[i].$2,
                body: _steps[i].$3,
                step: i + 1,
              ),
            ),
            if (i < _steps.length - 1)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.onSurfaceMuted),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final int step;
  const _StepCard(
      {required this.icon,
      required this.title,
      required this.body,
      required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceMuted,
                height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── City coverage row ─────────────────────────────────────────────────────────

class _CityRow extends StatelessWidget {
  const _CityRow();

  static const _cities = [
    'Mohali',
    'Chandigarh',
    'Panchkula',
    'Zirakpur',
    'Kharar',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: i == 0 ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: i == 0 ? AppColors.primary20 : AppColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 13,
                color: i == 0 ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
              const SizedBox(width: 4),
              Text(
                _cities[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      i == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

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
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
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
                        fontSize: 13,
                        color: Color(0xB3FFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _displayName(),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar — taps to Profile tab
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x33FFFFFF),
                    border: Border.all(
                        color: const Color(0x66FFFFFF), width: 2),
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
                              fontSize: 17,
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
          const SizedBox(height: 20),

          // Tagline pill + notification row
          Row(
            children: [
              // Tagline pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Report civic issues in your area',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Verified badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
