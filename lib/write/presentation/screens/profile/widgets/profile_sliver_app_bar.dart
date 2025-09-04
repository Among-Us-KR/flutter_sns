// lib/write/presentation/screens/profile/widgets/profile_sliver_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_collapsed_widget.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_header.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/stats_item.dart';

class ProfileSliverAppBar extends ConsumerWidget {
  // Use ConsumerWidget
  final VoidCallback onEditPressed;

  const ProfileSliverAppBar({super.key, required this.onEditPressed});

  static const double _statsOverflow = 80;
  static const double _headerHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final appBarH = kToolbarHeight + topPad;

    // 이 부분이 핵심입니다. userProfileProvider를 watch합니다.
    final userProfileAsync = ref.watch(userProfileProvider);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: cs.surface,
      expandedHeight:
          appBarH +
          ProfileSliverAppBar._headerHeight +
          (ProfileSliverAppBar._statsOverflow * 0.4),
      flexibleSpace: userProfileAsync.when(
        data: (user) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final minH = appBarH;
              final maxH =
                  appBarH +
                  ProfileSliverAppBar._headerHeight +
                  (ProfileSliverAppBar._statsOverflow * 0.4);
              final h = constraints.maxHeight.clamp(minH, maxH);
              final t = ((h - minH) / (maxH - minH)).clamp(0.0, 1.0);

              if (t > 0.5) {
                return _buildExpandedState(
                  context,
                  theme,
                  cs,
                  topPad,
                  appBarH,
                  ref,
                  user, // userProfile 객체를 전달
                );
              } else {
                return _buildCollapsedState(
                  context,
                  theme,
                  cs,
                  topPad,
                  appBarH,
                  ref,
                  user, // userProfile 객체를 전달
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('프로필 정보를 불러오지 못했습니다: $e')),
      ),
    );
  }

  Widget _buildExpandedState(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    double topPad,
    double appBarH,
    WidgetRef ref,
    user, // user 객체 받기
  ) {
    return Column(
      children: [
        Container(
          height: appBarH,
          color: cs.surface,
          padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('프로필', style: theme.textTheme.headlineLarge),
              ElevatedButton(
                onPressed: onEditPressed, // onEditPressed 사용
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondary,
                  foregroundColor: cs.onSecondary,
                  minimumSize: const Size(41, 30),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  '수정',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              ProfileSliverAppBar._headerHeight +
              (ProfileSliverAppBar._statsOverflow * 0.4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: ProfileSliverAppBar._headerHeight,
                color: cs.secondary,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: ProfileHeader(user: user), // user 객체 전달
              ),
              Positioned(
                top:
                    ProfileSliverAppBar._headerHeight -
                    (ProfileSliverAppBar._statsOverflow * 0.8),
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsItem(
                          count: user.stats.postsCount,
                          label: '던진 글',
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: StatsItem(
                          count: user.stats.likesReceived,
                          label: '받은 공감',
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: StatsItem(
                          count: user.stats.commentsReceived,
                          label: '받은 댓글',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedState(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    double topPad,
    double appBarH,
    WidgetRef ref,
    user, // user 객체 받기
  ) {
    return Container(
      height: appBarH,
      color: cs.surface,
      padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CollapsedAvatar(imageUrl: user.profileImageUrl), // 이미지 URL 전달
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname, // 닉네임 사용
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatInline(
                      theme: theme,
                      label: '글',
                      value: user.stats.postsCount,
                    ),
                    const StatDot(),
                    StatInline(
                      theme: theme,
                      label: '받은 공감',
                      value: user.stats.likesReceived,
                    ),
                    const StatDot(),
                    StatInline(
                      theme: theme,
                      label: '받은 댓글',
                      value: user.stats.commentsReceived,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onEditPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.secondary,
              foregroundColor: cs.onSecondary,
              minimumSize: const Size(41, 30),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              '수정',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
