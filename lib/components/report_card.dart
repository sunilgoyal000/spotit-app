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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use Theme.of(context).colorScheme.surface in widgets

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Thumbnail or Category Icon
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _categoryIcon(categoryColor),
                  ),
                )
              else
                _categoryIcon(categoryColor),

              const SizedBox(width: 12),

              // 📝 Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 🏷 Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // 🟢 Status Badge
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 📍 Location
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 📄 Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _categoryIcon(Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: color,
        size: 24,
      ),
    );
  }

  IconData _getCategoryIcon() {
    return switch (category.toLowerCase()) {
      'garbage' => Icons.delete_outline,
      'pothole' => Icons.construction_outlined,
      'water leakage' => Icons.water_drop_outlined,
      'streetlight' => Icons.lightbulb_outline,
      _ => Icons.report_problem_outlined,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    return switch (status) {
      'resolved' => AppColors.success,
      'in_progress' => Colors.blue,
      'rejected' => AppColors.error,
      _ => Colors.orange,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
