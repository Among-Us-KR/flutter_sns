import 'package:flutter/material.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_collapsed_widget.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_header.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/stats_item.dart';
import 'package:go_router/go_router.dart';

class ProfileSliverAppBar extends StatelessWidget {
  final VoidCallback onEditPressed;

  const ProfileSliverAppBar({super.key, required this.onEditPressed});

  static const double _statsOverflow = 80;
  static const double _headerHeight = 280;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final appBarH = kToolbarHeight + topPad;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: cs.surface,
      expandedHeight: appBarH + _headerHeight + (_statsOverflow * 0.4),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final minH = appBarH;
          final maxH = appBarH + _headerHeight + (_statsOverflow * 0.4);
          final h = constraints.maxHeight.clamp(minH, maxH);
          final t = ((h - minH) / (maxH - minH)).clamp(0.0, 1.0);

          // 간단한 분기: 0.5를 기준으로 완전히 다른 UI 표시
          if (t > 0.5) {
            // 펼쳐진 상태
            return _buildExpandedState(context, theme, cs, topPad, appBarH);
          } else {
            // 접힌 상태
            return _buildCollapsedState(context, theme, cs, topPad, appBarH);
          }
        },
      ),
    );
  }

  Widget _buildExpandedState(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    double topPad,
    double appBarH,
  ) {
    return Column(
      children: [
        // 상단 AppBar
        Container(
          height: appBarH,
          color: cs.surface,
          padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('프로필', style: theme.textTheme.headlineLarge),
              ElevatedButton(
                onPressed: () {
                  print('펼친 상태 수정 버튼 클릭됨');
                  context.pushNamed('profile_edit');
                },
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
        // 프로필 헤더 + 통계
        SizedBox(
          height: _headerHeight + (_statsOverflow * 0.4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: _headerHeight,
                color: cs.secondary,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: const ProfileHeader(),
              ),
              Positioned(
                top: _headerHeight - (_statsOverflow * 0.8),
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: StatsItem(count: 7, label: '던진 글')),
                      SizedBox(width: 7),
                      Expanded(child: StatsItem(count: 32, label: '받은 공감')),
                      SizedBox(width: 7),
                      Expanded(child: StatsItem(count: 14, label: '받은 팩폭')),
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
  ) {
    return Container(
      height: appBarH,
      color: cs.surface,
      padding: EdgeInsets.only(top: topPad, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CollapsedAvatar(imageUrl: null),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '화난강쥐',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatInline(theme: theme, label: '글', value: 7),
                    const StatDot(),
                    StatInline(theme: theme, label: '받은 공감', value: 32),
                    const StatDot(),
                    StatInline(theme: theme, label: '받은 팩폭', value: 14),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              print('접힌 상태 수정 버튼 클릭됨');
              context.pushNamed('profile_edit');
            },
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
