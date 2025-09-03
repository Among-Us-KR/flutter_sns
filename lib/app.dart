import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/core/services/message_service.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/contents_detail_page.dart';
import 'package:flutter_sns/write/presentation/screens/home/home_page.dart';
import 'package:flutter_sns/write/presentation/screens/login/login_detail_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_edit_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_page.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page.dart';
import 'package:flutter_sns/write/presentation/widgets/bottom_navigation.dart';
import 'package:flutter_sns/write/presentation/widgets/splash_page.dart';
import 'package:flutter_sns/write/presentation/screens/login/login_page.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      routerConfig: router, // 라우터 설정
      theme: AppTheme.lightTheme, // 라이트 테마
      darkTheme: AppTheme.darkTheme, // 다크 테마
      themeMode: ThemeMode.system, // 시스템 테마 모드
      scaffoldMessengerKey: SnackBarMessageService.scaffoldKey, // 스낵메시지
    );
  }
}

// 라우터 전역 설정
final GoRouter router = GoRouter(
  initialLocation: '/splash', // 스플래시 화면 먼저
  routes: [
    // Splash 화면
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/login-detail',
      name: 'login_detail',
      builder: (context, state) => const LoginDetailPage(),
    ),
    // 메인 앱 구조 (하단 탭 포함)
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
              builder: (context, state) => const HomePage(),
              routes: [
                // 상세 페이지는 상대 경로 사용!
                GoRoute(
                  path: 'post/:postId',
                  name: 'post_detail',
                  builder: (context, state) {
                    final postId = state.pathParameters['postId']!;
                    return ContentsDetailPage(postId: postId);
                  },
                ),
              ],
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
                GoRoute(
                  path: 'edit', // 상대 경로
                  name: 'profile_edit',
                  builder: (context, state) => ProfileEditPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/write',
      name: 'write',
      builder: (_, _) => const WritePage(),
    ),
  ],
);
