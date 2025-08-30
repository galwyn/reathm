import 'package:flutter/material.dart';

class ManageActivitiesPage extends StatefulWidget {
  final Map<String, bool> dailyActivities;

  const ManageActivitiesPage({Key? key, required this.dailyActivities}) : super(key: key);

  @override
  State<ManageActivitiesPage> createState() => _ManageActivitiesPageState();
}

class _ManageActivitiesPageState extends State<ManageActivitiesPage> {
  late Map<String, bool> _dailyActivities;

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
            return ListTile(
              title: Text(activity),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _dailyActivities.remove(activity);
                  });
                },
              ),
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
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
                          _dailyActivities[controller.text] = false;
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
