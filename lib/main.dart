import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/home/contents_detail_page.dart';
import 'package:flutter_sns/write/presentation/screens/home/home_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_edit_page.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_page.dart';
import 'package:flutter_sns/write/presentation/screens/write_page.dart';
import 'package:flutter_sns/write/presentation/widgets/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

// go_router 설정
final GoRouter _router = GoRouter(
  initialLocation: '/', // 홈 화면으로 시작되도록 설정
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
                    return ContentsDetailPage(postId: postId);
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
