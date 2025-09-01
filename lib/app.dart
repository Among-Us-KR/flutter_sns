import 'package:flutter/material.dart';
import 'package:flutter_sns/write/presentation/screens/home/home_page.dart';
import 'package:flutter_sns/write/presentation/screens/post_detail/post_detail_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_edit_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_page.dart';
import 'package:flutter_sns/write/presentation/screens/write_page.dart';
import 'package:flutter_sns/write/presentation/widgets/bottom_navigation.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '던져',
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

// Go Router 설정
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // 메인 네비게이션 (하단 탭바)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigation(navigationShell: navigationShell);
      },
      branches: [
        // 홈 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => HomePage(),
              routes: [
                // 홈에서 파생되는 상세 페이지들
                GoRoute(
                  path: '/post/:postId',
                  name: 'post_detail',
                  builder: (context, state) {
                    final postId = state.pathParameters['postId']!;
                    return PostDetailPage(postId: postId);
                  },
                ),
              ],
            ),
          ],
        ),

        // 글쓰기 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/write',
              name: 'write',
              builder: (context, state) => WritePage(),
            ),
          ],
        ),

        // 프로필 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => ProfilePage(),
              routes: [
                // 프로필에서 파생되는 페이지들
                GoRoute(
                  path: '/edit',
                  name: 'profile_edit',
                  builder: (context, state) => ProfileEditPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
