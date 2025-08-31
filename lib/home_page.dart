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
  Map<String, bool> _dailyActivities = {};

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affirmation Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _affirmation,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _generateNewAffirmationFromAI,
                          child: const Text('New Affirmation'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_up_outlined),
                          onPressed: () {
                            _saveAffirmationFeedback(true);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_down_outlined),
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
              ),
            ),
            const SizedBox(height: 20),

            // Grid for other cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Reflection Timer Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Reflection Timer',
                          style: Theme.of(context).textTheme.titleLarge,
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
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                              child: Text(_isTimerRunning ? 'Stop' : 'Start'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatDuration(_remainingSeconds),
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Daily Reminder Card
                /*
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Daily Reminder',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<int>(
                              value: _selectedHour,
                              items: List.generate(24, (index) => index).map((hour) {
                                return DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text(hour.toString().padLeft(2, '0')),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedHour = newValue!;
                                });
                              },
                            ),
                            const Text(':'),
                            DropdownButton<int>(
                              value: _selectedMinute,
                              items: List.generate(60, (index) => index).map((minute) {
                                return DropdownMenuItem<int>(
                                  value: minute,
                                  child: Text(minute.toString().padLeft(2, '0')),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedMinute = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _scheduleDailyReminder,
                          child: const Text('Set Reminder'),
                        ),
                      ],
                    ),
                  ),
                ),
                */
                // TODO: Re-enable daily reminder functionality
              ],
            ),
            const SizedBox(height: 20),

            // Daily Activities Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Activities',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: () async {
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
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._dailyActivities.keys.map((activity) {
                      return CheckboxListTile(
                        title: Text(activity),
                        value: _dailyActivities[activity],
                        onChanged: (newValue) async {
                          setState(() {
                            _dailyActivities[activity] = newValue!;
                          });
                          await _firestoreService.saveDailyActivities(widget.user.uid, _dailyActivities);
                          if (newValue == true) {
                            await _firestoreService.addAccomplishment(widget.user.uid, activity);
                            final encouragement = await _cloudFunctionService.generateEncouragement(activity);
                            _showEncouragement(encouragement);
                          }
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
