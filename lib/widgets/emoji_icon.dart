import 'package:flutter/material.dart';

class EmojiIcon extends StatelessWidget {
  final String emoji;

  const EmojiIcon({
    Key? key,
    required this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
