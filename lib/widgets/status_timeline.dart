import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  static const List<Map<String, String>> steps = [
    {'key': 'submitted', 'label': 'Submitted'},
    {'key': 'pending', 'label': 'In Review'},
    {'key': 'in_progress', 'label': 'Assigned'},
    {'key': 'resolved', 'label': 'Resolved'},
  ];

  int _currentIndex() {
    final index = steps.indexWhere((s) => s['key'] == status);
    return index == -1 ? 1 : index; // default → pending
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isDone = index <= current;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? Colors.green : Colors.grey,
                  size: 20,
                ),
                if (index != steps.length - 1)
                  Container(
                    height: 30,
                    width: 2,
                    color: isDone ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                steps[index]['label']!,
                style: TextStyle(
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
