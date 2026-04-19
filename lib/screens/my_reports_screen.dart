import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/report_card.dart';
import '../repositories/report_repository.dart';
import '../theme/colors.dart';
import 'report_details_screen.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  String _filter = 'All';

  static const _filters = ['All', 'Pending', 'In Progress', 'Resolved'];

  Color _getCategoryColor(String? category) {
    return switch (category?.toLowerCase()) {
      'garbage' => AppColors.garbage,
      'pothole' => AppColors.pothole,
      'water leakage' => AppColors.waterLeakage,
      'streetlight' => AppColors.streetlight,
      _ => AppColors.other,
    };
  }

  List<QueryDocumentSnapshot> _applyFilter(List<QueryDocumentSnapshot> docs) {
    if (_filter == 'All') return docs;
    final statusMap = {
      'Pending': 'pending',
      'In Progress': 'in_progress',
      'Resolved': 'resolved',
    };
    final target = statusMap[_filter];
    return docs.where((d) => (d.data() as Map)['status'] == target).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in again')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Filter Chips ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = f),
                      backgroundColor: AppColors.surfaceVariant,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.outline,
                        width: selected ? 1.5 : 1,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: Builder(
              builder: (context) {
                final reportsAsync = ref.watch(myReportsProvider(user.uid));

                return reportsAsync.when(
                  loading: () => _ShimmerList(),
                  error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(myReportsProvider(user.uid))),
                  data: (snapshot) {
                    final all = snapshot.docs;
                    final reports = _applyFilter(all);

                    // Empty state
                    if (reports.isEmpty) {
                      return _EmptyState(filter: _filter, allCount: all.length);
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => Future.value(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final doc = reports[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final categoryColor = _getCategoryColor(data['category']);

                          return ReportCard(
                            category: data['category'] ?? 'Unknown',
                            location: data['location'] ?? 'No location',
                            description: data['description'] ?? 'No description',
                            status: data['status'] ?? 'pending',
                            imageUrl: data['imageUrl'],
                            categoryColor: categoryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportDetailsScreen(report: doc),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Loading ───────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceVariant,
        highlightColor: Colors.white,
        child: Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const _ErrorState({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 34, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  final int allCount;

  const _EmptyState({required this.filter, required this.allCount});

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != 'All' && allCount > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No $filter reports' : 'No reports yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try selecting a different filter.'
                  : 'Spot a civic issue? Tap the button below to report it.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
