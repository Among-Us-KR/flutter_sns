import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 현재 라우트 확인
    final location = GoRouterState.of(context).uri.toString();
    final hideBottomBar = location.contains('/edit'); // edit일 때 숨김

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: hideBottomBar
          ? null
          : SafeArea(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/home_grey.png',
                      activeIconPath: 'assets/icons/home_orange.png',
                      index: 0,
                    ),
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/plus_grey.png',
                      activeIconPath: 'assets/icons/plus_orange.png',
                      index: 1,
                    ),
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/profile_grey.png',
                      activeIconPath: 'assets/icons/profile_orange.png',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconPath,
    required String activeIconPath,
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => navigationShell.goBranch(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? activeIconPath : iconPath,
              width: 24,
              height: 24,
              color: isActive ? theme.colorScheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
