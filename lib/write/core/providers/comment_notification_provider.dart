// lib/write/core/providers/comment_notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/comment_notification_service.dart';

final commentNotificationProvider = Provider<CommentNotificationService>((ref) {
  final service = CommentNotificationService();
  service.subscribeToComments();

  // 앱 종료 시 구독 해제
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
