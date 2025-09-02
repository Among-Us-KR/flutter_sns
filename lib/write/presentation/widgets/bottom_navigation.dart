import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 경로
    final location = GoRouterState.of(context).uri.toString();
    // 작성(/write)·프로필편집(/profile/edit)에서는 하단바 숨김
    final hideBottomBar =
        location.startsWith('/write') || location.startsWith('/profile/edit');

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
                    // 홈
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/home_grey.png',
                      activeIconPath: 'assets/icons/home_orange.png',
                      isActive: navigationShell.currentIndex == 0,
                      onTap: () => navigationShell.goBranch(0),
                    ),
                    // + (작성) — 브랜치 전환 대신 push로 별도 화면 오픈
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/plus_grey.png',
                      activeIconPath: 'assets/icons/plus_orange.png',
                      isActive: false, // 가운데 버튼은 활성 상태 없음
                      onTap: () => context.push('/write'),
                    ),
                    // 프로필
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/profile_grey.png',
                      activeIconPath: 'assets/icons/profile_orange.png',
                      isActive: navigationShell.currentIndex == 1,
                      onTap: () => navigationShell.goBranch(1),
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
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          isActive ? activeIconPath : iconPath,
          width: 24,
          height: 24,
          color: isActive ? theme.colorScheme.primary : Colors.grey,
        ),
      ),
    );
  }
}
