import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';

class HistoryPage extends StatefulWidget {
  final User user;

  const HistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<DocumentSnapshot> _accomplishments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccomplishments();
  }

  Future<void> _fetchAccomplishments() async {
    final snapshot = await _firestoreService.getAccomplishments(widget.user.uid);
    if (mounted) {
      setState(() {
        _accomplishments = snapshot.docs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accomplishments.isEmpty
              ? const Center(child: Text('No accomplishments yet.'))
              : RefreshIndicator(
                  onRefresh: _fetchAccomplishments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _accomplishments.length,
                    itemBuilder: (context, index) {
                      final accomplishment = _accomplishments[index];
                      final data = accomplishment.data() as Map<String, dynamic>;
                      final activity = data['activity'] as String;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final formattedDate = timestamp != null
                          ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                          : 'No date';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(activity, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(formattedDate),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}