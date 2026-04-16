import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/status_timeline.dart';
import '../theme/colors.dart';

class ReportDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final data = report.data() as Map<String, dynamic>;
    final String location = data['location'] ?? '';
    final String status = data['status'] ?? 'pending';
    final String category = data['category'] ?? 'Unknown';
    final String? imageUrl = data['imageUrl']?.toString();
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar (with optional hero image) ────────────────────────
          SliverAppBar(
            expandedHeight: hasImage ? 280 : 0,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.surface,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.onSurface,
                ),
              ),
            ),
            flexibleSpace: hasImage
                ? FlexibleSpaceBar(
                    background: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.onSurfaceMuted),
                      ),
                    ),
                  )
                : null,
          ),

          // ── Body ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Status
                  Row(
                    children: [
                      _CategoryBadge(category: category),
                      const Spacer(),
                      _StatusChip(status: status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),

                  if (data['district'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_city_rounded, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          data['district'],
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Progress Timeline ────────────────────────────────
                  _SectionCard(
                    title: 'Progress',
                    icon: Icons.timeline_rounded,
                    child: StatusTimeline(status: status),
                  ),

                  const SizedBox(height: 16),

                  // ── Description ───────────────────────────────────────
                  _SectionCard(
                    title: 'Description',
                    icon: Icons.description_rounded,
                    child: Text(
                      data['description'] ?? 'No description provided.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.onSurface,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Location ──────────────────────────────────────────
                  _SectionCard(
                    title: 'Location',
                    icon: Icons.location_on_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.isNotEmpty ? location : 'Not provided',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (location.contains(',')) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: const Text('Open in Maps'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            onPressed: () => _openMap(location),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Date ─────────────────────────────────────────────
                  _SectionCard(
                    title: 'Submitted',
                    icon: Icons.calendar_today_rounded,
                    child: Text(
                      data['createdAt'] != null
                          ? _formatDate((data['createdAt'] as Timestamp).toDate().toLocal())
                          : 'Unknown',
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
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

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openMap(String location) async {
    final parts = location.split(',');
    if (parts.length < 2) return;
    final uri = Uri.parse('https://maps.google.com/?q=${parts[0].trim()},${parts[1].trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Category Badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  Color get _color {
    return switch (category.toLowerCase()) {
      'garbage' => AppColors.garbage,
      'pothole' => AppColors.pothole,
      'water leakage' => AppColors.waterLeakage,
      'streetlight' => AppColors.streetlight,
      _ => AppColors.other,
    };
  }

  IconData get _icon {
    return switch (category.toLowerCase()) {
      'garbage' => Icons.delete_outline_rounded,
      'pothole' => Icons.construction_rounded,
      'water leakage' => Icons.water_drop_outlined,
      'streetlight' => Icons.lightbulb_outline_rounded,
      _ => Icons.report_problem_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color),
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    return switch (status) {
      'resolved' => AppColors.success,
      'in_progress' => AppColors.secondary,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };
  }

  String get _label {
    return switch (status) {
      'in_progress' => 'In Progress',
      'resolved' => 'Resolved',
      'rejected' => 'Rejected',
      _ => 'Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
