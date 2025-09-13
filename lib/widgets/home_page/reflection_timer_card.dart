import 'package:flutter/material.dart';
import 'package:reathm/theme/theme_extensions.dart';

class ReflectionTimerCard extends StatelessWidget {
  final String formattedDuration;
  final bool isTimerRunning;
  final double timerDuration;
  final ValueChanged<double?> onDurationChanged;
  final VoidCallback onStartStopPressed;

  const ReflectionTimerCard({
    Key? key,
    required this.formattedDuration,
    required this.isTimerRunning,
    required this.timerDuration,
    required this.onDurationChanged,
    required this.onStartStopPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reflection Timer',
              style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              formattedDuration,
              style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<double>(
                  value: timerDuration,
                  items: [0.5, 1.0, 2.0, 5.0, 10.0, 20.0].map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text('$value min'),
                    );
                  }).toList(),
                  onChanged: onDurationChanged,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTimerRunning ? Colors.redAccent : context.colors.primary,
                  ),
                  onPressed: onStartStopPressed,
                  child: Text(isTimerRunning ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
