import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'SpotIt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 13, color: Color(0xB3FFFFFF)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mission ─────────────────────────────────────────────
                  _Section(
                    icon: Icons.flag_rounded,
                    iconColor: AppColors.primary,
                    title: 'Our Mission',
                    child: const Text(
                      'SpotIt empowers citizens to report civic issues — potholes, garbage, broken streetlights, water leakages — directly to local authorities. '
                      'We believe that small reports lead to big change, and that every person has the power to make their city better.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Features ─────────────────────────────────────────────
                  _Section(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Key Features',
                    child: Column(
                      children: const [
                        _FeatureRow(
                          icon: Icons.camera_alt_rounded,
                          label: 'Photo Reports',
                          detail: 'Attach photos to make reports more credible and actionable.',
                        ),
                        _FeatureRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location Tagging',
                          detail: 'Pin the exact location of the issue on the map.',
                        ),
                        _FeatureRow(
                          icon: Icons.track_changes_rounded,
                          label: 'Live Status Tracking',
                          detail: 'Follow your report from Pending → In Progress → Resolved.',
                        ),
                        _FeatureRow(
                          icon: Icons.verified_rounded,
                          label: 'Authority Review',
                          detail: 'Reports are reviewed and actioned by local authorities.',
                        ),
                        _FeatureRow(
                          icon: Icons.bar_chart_rounded,
                          label: 'Personal Dashboard',
                          detail: 'See all your reports and their resolution status at a glance.',
                          last: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Coverage ─────────────────────────────────────────────
                  _Section(
                    icon: Icons.location_city_rounded,
                    iconColor: AppColors.warning,
                    title: 'Coverage',
                    child: _CoverageRow(),
                  ),

                  const SizedBox(height: 16),

                  // ── Built With ───────────────────────────────────────────
                  _Section(
                    icon: Icons.code_rounded,
                    iconColor: AppColors.onSurfaceVariant,
                    title: 'Built With',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _TechBadge('Flutter'),
                        _TechBadge('Firebase'),
                        _TechBadge('Firestore'),
                        _TechBadge('Firebase Auth'),
                        _TechBadge('Firebase Storage'),
                        _TechBadge('Material Design 3'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Contact ──────────────────────────────────────────────
                  _Section(
                    icon: Icons.mail_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'Contact & Support',
                    child: Column(
                      children: const [
                        _ContactRow(
                          icon: Icons.email_outlined,
                          label: 'support@spotit.app',
                        ),
                        SizedBox(height: 8),
                        _ContactRow(
                          icon: Icons.public_rounded,
                          label: 'www.spotit.app',
                        ),
                        SizedBox(height: 8),
                        _ContactRow(
                          icon: Icons.location_on_outlined,
                          label: 'Mohali, Punjab, India',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Footer ───────────────────────────────────────────────
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          '© 2025 SpotIt. All rights reserved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Making cities better, one report at a time.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    iconColor.r.toInt(), iconColor.g.toInt(), iconColor.b.toInt(), 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Feature row ───────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final bool last;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.detail,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!last) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ── Coverage row ──────────────────────────────────────────────────────────────

class _CoverageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const cities = ['Mohali', 'Chandigarh', 'Panchkula', 'Zirakpur'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cities.map((c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              c,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Tech badge ────────────────────────────────────────────────────────────────

class _TechBadge extends StatelessWidget {
  final String label;
  const _TechBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Contact row ───────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
