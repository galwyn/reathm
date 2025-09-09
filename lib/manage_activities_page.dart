import 'package:flutter/material.dart';
import 'package:reathm/theme/theme_extensions.dart';

import 'package:reathm/widgets/emoji_icon.dart';

class ManageActivitiesPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> dailyActivities;

  const ManageActivitiesPage({Key? key, required this.dailyActivities}) : super(key: key);

  @override
  State<ManageActivitiesPage> createState() => _ManageActivitiesPageState();
}

class _ManageActivitiesPageState extends State<ManageActivitiesPage> {
  late Map<String, Map<String, dynamic>> _dailyActivities;

  @override
  void initState() {
    super.initState();
    _dailyActivities = Map.from(widget.dailyActivities);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dailyActivities);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Activities'),
        ),
        body: ListView(
          children: _dailyActivities.keys.map((activity) {
            final emoji = _dailyActivities[activity]?['emoji'] as String? ?? '❓';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: EmojiIcon(emoji: emoji),
                title: Text(activity),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: context.colors.error),
                  onPressed: () {
                    setState(() {
                      _dailyActivities.remove(activity);
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller = TextEditingController();
                return AlertDialog(
                  title: Text('Add Activity'),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Activity Name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dailyActivities[controller.text] = {'completed': false, 'emoji': '😊'};
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
