import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'firestore_service.dart';
import 'package:reathm/theme/theme_extensions.dart';

class ActivityCalendarPage extends StatefulWidget {
  final User user;

  const ActivityCalendarPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ActivityCalendarPage> createState() => _ActivityCalendarPageState();
}

class _ActivityCalendarPageState extends State<ActivityCalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<String>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _firestoreService.getAccomplishedActivities(widget.user.uid);
  }

  Future<void> _showActivityCalendar(String activityName) async {
    final history = await _firestoreService.getActivityHistory(widget.user.uid, activityName);
    final events = { for (var item in history) DateTime.utc(item.year, item.month, item.day) : 'Completed' };

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activityName),
          content: SizedBox(
            width: double.maxFinite,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, day, focusedDay) {
                  final isCompleted = events[DateTime.utc(day.year, day.month, day.day)] != null;
                  final colorScheme = Theme.of(context).colorScheme;
                  if (isCompleted) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.primary, width: 2.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: context.colors.onSecondary),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.primary, width: 2.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: context.colors.primary),
                      ),
                    );
                  }
                },
                defaultBuilder: (context, day, focusedDay) {
                  final colorScheme = Theme.of(context).colorScheme;
                  if (events[DateTime.utc(day.year, day.month, day.day)] != null) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: context.colors.onSecondary),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading activities.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No accomplished activities yet.'));
          }

          final activities = snapshot.data!;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                title: Text(activity),
                onTap: () => _showActivityCalendar(activity),
              );
            },
          );
        },
      );
  }
}
