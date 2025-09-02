import 'package:flutter/material.dart';

class StatsItem extends StatelessWidget {
  final int count;
  final String label;

  const StatsItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4), // X, Y
            blurRadius: 4, // Blur
            spreadRadius: 0, // Spread
            color: Color.fromRGBO(0, 0, 0, 0.10), // #000000, 10%
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.displayLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
