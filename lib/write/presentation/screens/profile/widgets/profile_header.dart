import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 프로필 이미지
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 4),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_placeholder.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 닉네임
        Text(
          '화난강쥐',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
