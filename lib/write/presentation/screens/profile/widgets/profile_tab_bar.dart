import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {
  final TabController tabController;

  const ProfileTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarHeaderDelegate(
        child: Container(
          color: cs.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: TabBar(
                controller: tabController,
                dividerHeight: 0,
                labelColor: cs.primary,
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelColor: cs.onSurfaceVariant,
                unselectedLabelStyle: theme.textTheme.titleMedium,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: cs.primary),
                  insets: EdgeInsets.zero,
                ),
                tabs: const [
                  Tab(height: 32, child: Text('내 글')),
                  Tab(height: 32, child: Text('내 댓글')),
                  Tab(height: 32, child: Text('내 공감')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _TabBarHeaderDelegate({required this.child});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
