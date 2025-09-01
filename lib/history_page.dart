import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';

class HistoryPage extends StatefulWidget {
  final User user;

  const HistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late DateTime _selectedDay;
  late Future<List<String>> _accomplishmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAccomplishments();
  }

  void _loadAccomplishments() {
    setState(() {
      _accomplishmentsFuture = _firestoreService.getAccomplishmentsForDay(widget.user.uid, _selectedDay);
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
      _loadAccomplishments();
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
      _loadAccomplishments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _goToPreviousDay,
              ),
              Text(
                DateFormat.yMMMd().format(_selectedDay),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _goToNextDay,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _accomplishmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading accomplishments.'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No accomplishments for this day.'));
              }

              final accomplishments = snapshot.data!;

              return ListView.builder(
                itemCount: accomplishments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(accomplishments[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}