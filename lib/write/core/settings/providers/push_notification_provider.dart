// 사용자 알림 설정 상태 관리 Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationProvider = StateProvider<bool>((ref) => true);
