import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ReportCard extends StatelessWidget {
  final String category;
  final String location;
  final String description;
  final String status;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Color categoryColor;

  const ReportCard({
    super.key,
    required this.category,
    required this.location,
    required this.description,
    required this.status,
    this.imageUrl,
    this.onTap,
    required this.categoryColor,
  });

  IconData get _categoryIcon {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
          boxShadow: AppColors.cardShadow,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail / Icon ──────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _IconBox(color: categoryColor, icon: _categoryIcon),
                        )
                      : _IconBox(color: categoryColor, icon: _categoryIcon),
                ),

                const SizedBox(width: 14),

                // ── Content ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: category badge + status
                      Row(
                        children: [
                          _CategoryTag(label: category, color: categoryColor),
                          const Spacer(),
                          _StatusBadge(status: status),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.onSurfaceMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IconBox({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      color: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
