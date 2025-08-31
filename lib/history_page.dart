import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final User user;

  const HistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDay = DateTime.now();

  void _goToPreviousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
    });
  }

  Widget build(BuildContext context) {
    print('Building HistoryPage for user: ${widget.user.uid}');
    return Column(
      children: [
        _buildDateNavigator(),
        _buildActivitiesList(),
      ],
    );
  }

  Widget _buildDateNavigator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToPreviousDay,
          ),
          Text(
            DateFormat('MMMM d, yyyy').format(_selectedDay),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextDay,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    final date = DateFormat('yyyy-MM-dd').format(_selectedDay);

    return Expanded(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('daily_activities')
            .doc(date)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No activities for this day.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final activities = Map<String, bool>.from(data['activities'] ?? {});

          if (activities.isEmpty) {
            return const Center(child: Text('No activities for this day.'));
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities.keys.elementAt(index);
              final completed = activities[activity]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: completed ? const Icon(Icons.check_box, color: Colors.green) : const Icon(Icons.check_box_outline_blank, color: Colors.grey),
                  title: Text(activity),
                ),
              );
            },
          );
        },
      ),
    );
  }

  
}
