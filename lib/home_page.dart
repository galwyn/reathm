import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cloud_function_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'manage_activities_page.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'firestore_service.dart';
import 'widgets/task_item.dart';
import 'widgets/home_page/affirmation_card.dart';
import 'widgets/home_page/reflection_timer_card.dart';
import 'widgets/home_page/daily_activities_card.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CloudFunctionService _cloudFunctionService = CloudFunctionService();
  final NotificationService _notificationService = NotificationService();
  final FirestoreService _firestoreService = FirestoreService();
  String _affirmation = 'Loading affirmation...';
  Map<String, Map<String, dynamic>> _dailyActivities = {};

  int _selectedHour = 8; // Default reminder hour
  int _selectedMinute = 0; // Default reminder minute

  double _timerDuration = 5.0;
  Timer? _timer;
  int _remainingSeconds = 300;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _getInitialAffirmation(); // Call the new method for initial load
    _remainingSeconds = (_timerDuration * 60).toInt();
    _firestoreService.getDailyActivities(widget.user.uid).then((activities) {
      setState(() {
        _dailyActivities = activities;
      });
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
    // Try to get a random seeded affirmation first
    final seededAffirmation = await _firestoreService.getRandomSeededAffirmation();
    if (seededAffirmation != null) {
      setState(() {
        _affirmation = seededAffirmation;
      });
      return;
    }

    // If no seeded affirmations, generate an AI affirmation
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

  Future<void> _scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedHour,
      _selectedMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reathm Reminder',
      'Time for your daily affirmation and activities!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Daily reminder for Reathm app',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    _showEncouragement('Daily reminder set for $_selectedHour:$_selectedMinute');
  }

  Future<void> _saveAffirmationFeedback(bool liked) async {
    await _firestoreService.addAffirmationFeedback(
      widget.user.uid,
      _affirmation,
      liked,
    );
  }

  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Affirmation Section
                  AffirmationCard(
                    affirmation: _affirmation,
                    onNewAffirmation: _generateNewAffirmationFromAI,
                    onFeedback: (liked) {
                      _saveAffirmationFeedback(liked);
                      if (!liked) {
                        _cloudFunctionService.generateNewAffirmation(_affirmation).then((newAffirmation) {
                          setState(() {
                            _affirmation = newAffirmation;
                          });
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Main Content Grid
                  ReflectionTimerCard(
                    formattedDuration: _formatDuration(_remainingSeconds),
                    isTimerRunning: _isTimerRunning,
                    timerDuration: _timerDuration,
                    onDurationChanged: (newValue) {
                      setState(() {
                        _timerDuration = newValue!;
                        _remainingSeconds = (_timerDuration * 60).toInt();
                      });
                    },
                    onStartStopPressed: _isTimerRunning ? _stopTimer : _startTimer,
                  ),
                  const SizedBox(height: 20),

                  // Daily Activities Section
                  DailyActivitiesCard(
                    dailyActivities: _dailyActivities,
                    onActivityChanged: (activity, newValue) async {
                      setState(() {
                        _dailyActivities[activity]?['completed'] = newValue;
                      });
                      await _firestoreService.saveDailyActivities(widget.user.uid, _dailyActivities);
                      if (newValue == true) {
                        await _firestoreService.addAccomplishment(widget.user.uid, activity);
                        final encouragement = await _cloudFunctionService.generateEncouragement(activity);
                        _showEncouragement(encouragement);
                      }
                    },
                    onManage: () async {
                      final updatedActivities = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageActivitiesPage(dailyActivities: _dailyActivities),
                        ),
                      );
                      if (updatedActivities != null) {
                        setState(() {
                          _dailyActivities = updatedActivities;
                        });
                        await _firestoreService.saveDailyActivities(widget.user.uid, _dailyActivities);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
