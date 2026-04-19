import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class ReportCard extends StatelessWidget {
  final String category;
  final String location;
  final String description;
  final String status;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Color categoryColor;
  final Timestamp? createdAt;

  const ReportCard({
    super.key,
    required this.category,
    required this.location,
    required this.description,
    required this.status,
    required this.categoryColor,
    this.imageUrl,
    this.onTap,
    this.createdAt,
  });

  IconData get _icon => switch (category.toLowerCase()) {
        'garbage' => Icons.delete_outline_rounded,
        'pothole' => Icons.construction_rounded,
        'water leakage' => Icons.water_drop_outlined,
        'streetlight' => Icons.lightbulb_outline_rounded,
        _ => Icons.report_problem_outlined,
      };

  String _timeAgo() {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!.toDate());
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image / Banner ─────────────────────────────────────────
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            height: 168,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _Banner(color: categoryColor, icon: _icon),
                          )
                        : _Banner(color: categoryColor, icon: _icon),
                  ),

                  // ── Content ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category + Status
                        Row(
                          children: [
                            _CategoryPill(
                                label: category, color: categoryColor),
                            const Spacer(),
                            _StatusDot(status: status),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Footer: location + time
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 13, color: AppColors.onSurfaceMuted),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (createdAt != null)
                              Text(
                                _timeAgo(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner placeholder ────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _Banner({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      color: Color.fromRGBO(
          color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.06),
      child: Center(
        child: Icon(
          icon,
          size: 42,
          color: Color.fromRGBO(
              color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.35),
        ),
      ),
    );
  }
}

// ── Category pill ─────────────────────────────────────────────────────────────

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
            color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Status dot + label ────────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  Color get _color => switch (status) {
        'resolved' => AppColors.success,
        'in_progress' => AppColors.secondary,
        'rejected' => AppColors.error,
        _ => AppColors.warning,
      };

  String get _label => switch (status) {
        'in_progress' => 'In Progress',
        'resolved' => 'Resolved',
        'rejected' => 'Rejected',
        _ => 'Pending',
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          _label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}
