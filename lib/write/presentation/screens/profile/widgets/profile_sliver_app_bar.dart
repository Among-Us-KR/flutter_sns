import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_collapsed_widget.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_header.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/stats_item.dart';

class ProfileSliverAppBar extends ConsumerWidget {
  final List<Widget>? actions;

  const ProfileSliverAppBar({super.key, this.actions});

  static const double _statsOverflow = 80;
  static const double _headerHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final appBarH = kToolbarHeight + topPad;

    final userProfileAsync = ref.watch(userProfileProvider);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: cs.surface,
      expandedHeight: appBarH + _headerHeight + (_statsOverflow * 0.4),
      actions: actions, // ✅ actions 매개변수 추가
      flexibleSpace: userProfileAsync.when(
        data: (user) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final minH = appBarH;
              final maxH = appBarH + _headerHeight + (_statsOverflow * 0.4);
              final h = constraints.maxHeight.clamp(minH, maxH);
              final t = ((h - minH) / (maxH - minH)).clamp(0.0, 1.0);

              if (t > 0.5) {
                return _buildExpandedState(
                  context,
                  theme,
                  cs,
                  topPad,
                  appBarH,
                  user,
                );
              } else {
                return _buildCollapsedState(
                  context,
                  theme,
                  cs,
                  topPad,
                  appBarH,
                  user,
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
    user,
  ) {
    // 단일 Stack을 사용하여 모든 요소를 올바른 위치에 배치
    return Stack(
      children: [
        // 메인 헤더 영역
        Positioned(
          top: appBarH,
          left: 0,
          right: 0,
          height: _headerHeight,
          child: Container(
            color: cs.secondary,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: ProfileHeader(user: user),
          ),
        ),
        // 통계 카드 영역 (헤더에 겹치도록 배치)
        Positioned(
          top: appBarH + _headerHeight - (_statsOverflow * 0.8),
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            // 하얀색 배경 및 그림자 제거
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // 배경색과 그림자 제거
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
        ),
        // 상단 AppBar 영역 (가장 위로 배치)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: appBarH,
          child: Container(
            color: cs.surface,
            padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('프로필', style: theme.textTheme.headlineLarge),
                // 여기에서 버튼을 제거했습니다.
              ],
            ),
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
    user,
  ) {
    return Container(
      height: appBarH,
      color: cs.surface,
      padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CollapsedAvatar(imageUrl: user.profileImageUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
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
        ],
      ),
    );
  }
}
