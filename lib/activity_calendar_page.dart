import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'firestore_service.dart';

class ActivityCalendarPage extends StatefulWidget {
  final User user;

  const ActivityCalendarPage({super.key, required this.user});

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
    if (!mounted) return;
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
                  if (isCompleted) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purple.shade300, width: 2.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purple.shade300, width: 2.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.purple.shade300),
                      ),
                    );
                  }
                },
                defaultBuilder: (context, day, focusedDay) {
                  if (events[DateTime.utc(day.year, day.month, day.day)] != null) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
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
