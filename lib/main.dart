import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sns/app.dart'; // App 위젯 import
import 'package:flutter_sns/firebase_options.dart';
import 'package:flutter_sns/utils/xss.dart';  // 방금 만든 xss.dart import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 금지어 CSV 로딩 (앱 시작 전에 반드시 호출)
  await XssFilter.loadBannedWordsFromCSV();

  // 앱 실행
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
