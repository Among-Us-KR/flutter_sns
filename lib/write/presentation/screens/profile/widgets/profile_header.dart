import 'package:flutter/material.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;

class ProfileHeader extends StatelessWidget {
  final domain.User user;

  const ProfileHeader({super.key, required this.user});

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
            child: user.profileImageUrl != null
                ? Image.network(
                    user.profileImageUrl!,
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // 닉네임
        Text(
          user.nickname,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
