import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reathm/models/activity.dart';
import 'package:uuid/uuid.dart';
import 'firestore_service.dart';

class ManageActivitiesPage extends StatefulWidget {
  final List<Activity> dailyActivities;
  final User user;

  const ManageActivitiesPage({super.key, required this.dailyActivities, required this.user});

  @override
  State<ManageActivitiesPage> createState() => _ManageActivitiesPageState();
}

class _ManageActivitiesPageState extends State<ManageActivitiesPage> {
  late List<Activity> _dailyActivities;
  final Uuid _uuid = const Uuid();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _dailyActivities = List.from(widget.dailyActivities);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, _dailyActivities);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Activities'),
        ),
        body: ListView.builder(
          itemCount: _dailyActivities.length,
          itemBuilder: (context, index) {
            final activity = _dailyActivities[index];
            return SwitchListTile(
              title: Text(activity.name),
              value: activity.isActive,
              onChanged: (bool value) {
                setState(() {
                  final updatedActivity = activity.copyWith(isActive: value);
                  _dailyActivities[index] = updatedActivity;
                  _firestoreService.updateDailyActivity(widget.user.uid, updatedActivity);
                });
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller = TextEditingController();
                return AlertDialog(
                  title: const Text('Add Activity'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Activity Name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          setState(() {
                            final newActivity = Activity(
                              id: _uuid.v4(),
                              name: controller.text,
                              emoji: '📝', // Default emoji
                            );
                            _dailyActivities.add(newActivity);
                            _firestoreService.addDailyActivity(widget.user.uid, newActivity);
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
