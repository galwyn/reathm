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

  void _addActivity(String name) {
    setState(() {
      final newActivity = Activity(
        id: _uuid.v4(),
        name: name,
        emoji: '📝', // Default emoji
      );
      _dailyActivities.add(newActivity);
      _firestoreService.addDailyActivity(widget.user.uid, newActivity);
    });
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
          onPressed: () async {
            final newActivityName = await showDialog<String>(
              context: context,
              builder: (context) {
                return _AddActivityDialog(dailyActivities: _dailyActivities);
              },
            );

            if (newActivityName != null && newActivityName.isNotEmpty) {
              _addActivity(newActivityName);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AddActivityDialog extends StatefulWidget {
  final List<Activity> dailyActivities;

  const _AddActivityDialog({required this.dailyActivities});

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _submit() {
    final newActivityName = _controller.text.trim();
    if (newActivityName.isEmpty) {
      setState(() {
        _errorMessage = 'Activity name cannot be empty.';
      });
      return;
    }

    final isDuplicate = widget.dailyActivities.any((activity) => activity.name.toLowerCase() == newActivityName.toLowerCase());

    if (isDuplicate) {
      setState(() {
        _errorMessage = 'This activity already exists.';
      });
    } else {
      Navigator.pop(context, newActivityName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Activity'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Activity Name',
          errorText: _errorMessage,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
