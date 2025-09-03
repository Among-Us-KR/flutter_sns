// widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_page_view_model.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ProfileViewModel에서 현재 사용자 정보 가져오기 (null = 현재 사용자)
    final profileState = ref.watch(profileViewModelProvider(null));

    // 로딩 중일 때
    if (profileState.isLoading) {
      return Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 4),
              color: colorScheme.surfaceContainerHigh,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    // 사용자 정보가 없을 때
    if (profileState.user == null) {
      return Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 4),
              color: colorScheme.surfaceContainerHigh,
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '사용자 정보 없음',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onSecondary,
            ),
          ),
        ],
      );
    }

    final user = profileState.user!;

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
