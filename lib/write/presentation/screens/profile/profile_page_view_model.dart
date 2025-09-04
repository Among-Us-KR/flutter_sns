import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/domain/usecases/profile_usecase/get_user_profile_usecase.dart';

import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_stats_usecase.dart';

//State
class ProfileState {
  final domain.User? user;

  // 로딩 상태
  final bool isLoading;

  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    domain.User? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

//ViewModel
class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase _getUserProfile;

  final UpdateUserStatsUseCase _updateUserStats;

  ProfileViewModel({
    required GetUserProfileUseCase getUserProfile,
    required UpdateUserStatsUseCase updateUserStats,
  }) : _getUserProfile = getUserProfile,
       _updateUserStats = updateUserStats,

       super(const ProfileState());

  // 현재 로그인 사용자 로드
  Future<void> loadCurrentUser() async {
    final uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }
    await loadByUid(uid);
  }

  /// 특정 UID 로드 (타 사용자 프로필 조회 시)
  Future<void> loadByUid(String uid) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      final u = await _getUserProfile.execute(uid);

      // 드래프트 초기화
      state = state.copyWith(isLoading: false, user: u);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 통계 업데이트(예: 게시글/공감/팩폭 카운트 갱신)
  Future<void> updateStats(domain.UserStats stats) async {
    if (state.user == null) return;
    try {
      await _updateUserStats.execute(state.user!.uid, stats);
      // 로컬에도 반영
      state = state.copyWith(user: state.user!.copyWith(stats: stats));
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // 스트림으로부터 통계 데이터를 받아 상태를 업데이트하는 메서드
  void updateStatsFromStream(domain.UserStats newStats) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(stats: newStats);
    state = state.copyWith(user: updatedUser);
  }

  /// 메시지 클리어 (Snackbar 이후)
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
