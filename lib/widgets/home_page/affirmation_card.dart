import 'package:flutter/material.dart';
import 'package:reathm/theme/theme_extensions.dart';

class AffirmationCard extends StatelessWidget {
  final String affirmation;
  final VoidCallback onNewAffirmation;
  final Function(bool) onFeedback;

  const AffirmationCard({
    Key? key,
    required this.affirmation,
    required this.onNewAffirmation,
    required this.onFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              affirmation,
              style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onNewAffirmation,
                  child: const Text('New Affirmation'),
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  color: Colors.green,
                  onPressed: () => onFeedback(true),
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_down_outlined),
                  color: Colors.red,
                  onPressed: () => onFeedback(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
