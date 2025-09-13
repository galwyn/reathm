import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cloud_function_service.dart';
import 'notification_service.dart';
import 'manage_activities_page.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:reathm/models/activity.dart';
import 'firestore_service.dart';

class HomePage extends StatefulWidget {
  final User user;
  final FirestoreService? firestoreService;
  final CloudFunctionService? cloudFunctionService;
  final NotificationService? notificationService;

  const HomePage({
    super.key,
    required this.user,
    this.firestoreService,
    this.cloudFunctionService,
    this.notificationService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CloudFunctionService _cloudFunctionService;
  late final FirestoreService _firestoreService;
  String _affirmation = 'Loading affirmation...';
  List<Activity> _dailyActivities = [];
  List<String> _todaysAccomplishments = [];

  double _timerDuration = 5.0;
  Timer? _timer;
  int _remainingSeconds = 300;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = widget.firestoreService ?? FirestoreService();
    _cloudFunctionService = widget.cloudFunctionService ?? CloudFunctionService();
    tzdata.initializeTimeZones();
    _getInitialAffirmation();
    _loadActivities();
    _remainingSeconds = (_timerDuration * 60).toInt();
  }

  Future<void> _loadActivities() async {
    final activities = await _firestoreService.getActiveActivities(widget.user.uid);
    final accomplishments = await _firestoreService.getAccomplishmentsForDay(widget.user.uid, DateTime.now());
    setState(() {
      _dailyActivities = activities;
      _todaysAccomplishments = accomplishments;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _showEncouragement('Reflection complete!');
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = (_timerDuration * 60).toInt();
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _getInitialAffirmation() async {
    final seededAffirmation = await _firestoreService.getRandomSeededAffirmation();
    if (seededAffirmation != null) {
      setState(() {
        _affirmation = seededAffirmation;
      });
      return;
    }
    await _generateNewAffirmationFromAI();
  }

  Future<void> _generateNewAffirmationFromAI() async {
    final newAffirmation = await _cloudFunctionService.generateAffirmation('a unique, uplifting, and personalized affirmation about self-growth and resilience, between 8 and 14 words long');
    setState(() {
      _affirmation = newAffirmation;
    });
  }

  void _showEncouragement(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveAffirmationFeedback(bool liked) async {
    await _firestoreService.addAffirmationFeedback(
      widget.user.uid,
      _affirmation,
      liked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme.copyWith(
      primary: Colors.deepPurple.shade300,
      secondary: Colors.orange.shade300,
      surface: Colors.grey.shade100,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAffirmationSection(colorScheme),
                  const SizedBox(height: 20),
                  _buildMainGrid(colorScheme),
                  const SizedBox(height: 20),
                  _buildDailyActivitiesSection(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAffirmationSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _affirmation,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _generateNewAffirmationFromAI,
                child: const Text('New Affirmation'),
              ),
              IconButton(
                icon: const Icon(Icons.thumb_up_outlined),
                color: Colors.green,
                onPressed: () => _saveAffirmationFeedback(true),
              ),
              IconButton(
                icon: const Icon(Icons.thumb_down_outlined),
                color: Colors.red,
                onPressed: () {
                  _saveAffirmationFeedback(false);
                  _cloudFunctionService.generateNewAffirmation(_affirmation).then((newAffirmation) {
                    setState(() {
                      _affirmation = newAffirmation;
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainGrid(ColorScheme colorScheme) {
    return _buildReflectionTimer(colorScheme);
  }

  Widget _buildReflectionTimer(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reflection Timer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _formatDuration(_remainingSeconds),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<double>(
                value: _timerDuration,
                items: [0.5, 1.0, 2.0, 5.0, 10.0, 20.0].map((double value) {
                  return DropdownMenuItem<double>(
                    value: value,
                    child: Text('$value min'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _timerDuration = newValue!;
                    _remainingSeconds = (_timerDuration * 60).toInt();
                  });
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTimerRunning ? Colors.redAccent : colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                child: Text(_isTimerRunning ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivitiesSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push<List<Activity>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageActivitiesPage(dailyActivities: _dailyActivities, user: widget.user),
                    ),
                  );
                  _loadActivities();
                },
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._dailyActivities.map((activity) {
            final isCompleted = _todaysAccomplishments.contains(activity.name);
            return CheckboxListTile(
              title: Text(activity.name),
              value: isCompleted,
              onChanged: (newValue) async {
                if (newValue != null) {
                  await _firestoreService.setActivityCompletedStatus(widget.user.uid, activity.name, newValue);
                  setState(() {
                    if (newValue) {
                      _todaysAccomplishments.add(activity.name);
                    } else {
                      _todaysAccomplishments.remove(activity.name);
                    }
                  });
                  if (newValue == true) {
                    final encouragement = await _cloudFunctionService.generateEncouragement(activity.name);
                    _showEncouragement(encouragement);
                  }
                }
              },
              activeColor: colorScheme.primary,
            );
          }),
        ],
      ),
    );
  }
}
