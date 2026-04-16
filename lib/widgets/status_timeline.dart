import 'package:flutter/material.dart';
import '../theme/colors.dart';

class StatusTimeline extends StatelessWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  static const List<Map<String, String>> _steps = [
    {'key': 'submitted', 'label': 'Submitted', 'desc': 'Report received'},
    {'key': 'pending', 'label': 'In Review', 'desc': 'Being reviewed by team'},
    {'key': 'in_progress', 'label': 'In Progress', 'desc': 'Assigned to authority'},
    {'key': 'resolved', 'label': 'Resolved', 'desc': 'Issue has been fixed'},
  ];

  int _currentIndex() {
    final index = _steps.indexWhere((s) => s['key'] == status);
    return index == -1 ? 1 : index;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex();

    return Column(
      children: List.generate(_steps.length, (index) {
        final isDone = index < current;
        final isActive = index == current;
        final isPending = index > current;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: dot + connector line ──────────────────────────────
            Column(
              children: [
                // Step dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.outline,
                    border: Border.all(
                      color: isDone
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : AppColors.outline,
                      width: isActive ? 2.5 : 0,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                        : isActive
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.onSurfaceMuted.withValues(alpha: 0.5),
                                ),
                              ),
                  ),
                ),

                // Connector line (not after last step)
                if (index != _steps.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.success : AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Right: label + description ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[index]['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
                        color: isPending ? AppColors.onSurfaceMuted : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _steps[index]['desc']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPending ? AppColors.onSurfaceMuted : AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (index != _steps.length - 1) const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
