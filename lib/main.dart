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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 로컬 알림 초기화
  await NotificationService.init();

  // 금지어 CSV 로딩
  await XssFilter.loadBannedWordsFromCSV();

  // 로그인된 사용자에 대해 댓글 알림 구독 시작
  _subscribeToCommentNotifications();

  // 앱 실행
  runApp(const ProviderScope(child: MyApp()));
}

/// 로그인 상태에 따라 댓글 알림 구독 시작
void _subscribeToCommentNotifications() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    CommentNotificationService().subscribeToComments();
  }

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      CommentNotificationService().subscribeToComments();
    }
  });
}
