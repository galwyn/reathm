import 'package:flutter/material.dart';
import 'package:reathm/theme/theme_extensions.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TaskItem({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: value ? context.colors.secondary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: context.colors.secondary,
            ),
            const SizedBox(width: 16.0),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
