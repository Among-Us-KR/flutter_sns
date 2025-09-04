import 'package:flutter/material.dart';
import 'package:flutter_sns/app.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 현재 경로
    final location = GoRouterState.of(context).uri.toString();
    // 작성(/write)·프로필편집(/profile/edit), 게시글편집에서는 하단바 숨김
    final hideBottomBar =
        location.startsWith('/write') ||
        location.startsWith('/profile/edit') ||
        location.startsWith('/post/detail');

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
                      iconPath: 'assets/icons/plus_button.png',
                      activeIconPath: 'assets/icons/plus_button.png',
                      isActive: false,
                      size: 36,
                      tint: false,
                      onTap: () => context.push('/write'),
                    ),

                    // 프로필
                    _buildNavItem(
                      context,
                      iconPath: 'assets/icons/profile_grey.png',
                      activeIconPath: 'assets/icons/profile_orange.png',
                      isActive: navigationShell.currentIndex == 1,
                      onTap: () {
                        navigationShell.goBranch(1);

                        // ✅ 탭 진입마다 강제 갱신 시도
                        final state = profileTabKey.currentState;
                        // state에 refresh()가 정의되어 있으면 호출
                        // (앞서 제공한 ProfilePage 코드에는 Future<void> refresh()가 구현되어 있습니다)
                        if (state != null) {
                          // dynamic 호출 (private State 타입 노출 없이)
                          final dynamic dynState = state;
                          try {
                            final Future<void> f = dynState.refresh();
                            // 에러 무시 가능하지만 원하면 f.catchError(...)로 로깅
                          } catch (_) {
                            /* no-op */
                          }
                        }
                      },
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
    double size = 24,
    bool tint = true,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          isActive ? activeIconPath : iconPath,
          width: size,
          height: size,
          color: tint
              ? (isActive ? theme.colorScheme.primary : Colors.grey)
              : null,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
