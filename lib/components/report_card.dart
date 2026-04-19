import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Wrapped in RepaintBoundary so the GPU layer is cached.
/// No BoxShadow — shadows on ListView items force a repaint on every scroll frame.
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
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Thumbnail / Icon ──────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _IconBox(color: categoryColor, icon: _categoryIcon),
                          )
                        : _IconBox(color: categoryColor, icon: _categoryIcon),
                  ),

                  const SizedBox(width: 12),

                  // ── Content ──────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CategoryTag(label: category, color: categoryColor),
                            const Spacer(),
                            _StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: AppColors.onSurfaceMuted,
                            ),
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
                        const SizedBox(height: 4),
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
    return SizedBox(
      width: 64,
      height: 64,
      child: ColoredBox(
        color: Color.fromRGBO(
          color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        child: Icon(icon, color: color, size: 26),
      ),
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
        color: Color.fromRGBO(
          color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Color.fromRGBO(c.r.toInt(), c.g.toInt(), c.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
