import 'package:flutter/material.dart';
import 'package:reathm/theme/theme_extensions.dart';
import 'package:reathm/widgets/task_item.dart';

class DailyActivitiesCard extends StatelessWidget {
  final Map<String, Map<String, dynamic>> dailyActivities;
  final Function(String, bool) onActivityChanged;
  final VoidCallback onManage;

  const DailyActivitiesCard({
    Key? key,
    required this.dailyActivities,
    required this.onActivityChanged,
    required this.onManage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Activities',
                  style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton(
                  onPressed: onManage,
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (dailyActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No daily activities yet. Tap "Manage" to add some!',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...dailyActivities.keys.map((activity) {
                return TaskItem(
                  title: activity,
                  value: dailyActivities[activity]?['completed'] ?? false,
                  onChanged: (newValue) => onActivityChanged(activity, newValue!),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
