import 'package:flutter/material.dart';

// 리스트가 빈 상태일 때 보여지는 위젯
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
