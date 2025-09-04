// 앱 초기화 및 실행
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sns/app.dart';
import 'package:flutter_sns/firebase_options.dart';
import 'package:flutter_sns/utils/xss.dart';
import 'package:flutter_sns/utils/notification_service.dart';
import 'package:flutter_sns/write/core/services/comment_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 로컬 알림 초기화
  await NotificationService.init();

  // 금지어 CSV 로딩
  await XssFilter.loadBannedWordsFromCSV();

  // 앱 실행
  runApp(const Root());
}

/// 로그인 상태에 따라 ProviderScope 전체를 초기화 + 댓글 알림 구독
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // 로그인된 경우 → 댓글 알림 구독 시작
        if (user != null) {
          CommentNotificationService().subscribeToComments();
        }

        // 로그인/로그아웃이 바뀔 때마다 ProviderScope 전체 리셋
        return ProviderScope(
          key: ValueKey(user?.uid), // uid 달라지면 ProviderScope 재생성
          child: const MyApp(),
        );
      },
    );
  }
}
