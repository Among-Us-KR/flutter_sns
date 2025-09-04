import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/domain/usecases/profile_usecase/check_nickname_duplicate_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/get_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_stats_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/upload_profile_image_usecase.dart';

//State
class ProfileState {
  final domain.User? user;

  // 로딩 상태
  final bool isLoading;
  final bool isSaving;

  // 닉네임 검사 상태
  final bool isCheckingNickname;
  final String? nicknameError;

  // 편집 드래프트
  final String nicknameDraft;
  final File? imageDraft; // 새로 선택된 이미지(선택 안했으면 null)
  final bool? pushDraft; // null이면 변경 없음

  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.isCheckingNickname = false,
    this.nicknameError,
    this.nicknameDraft = '',
    this.imageDraft,
    this.pushDraft,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    domain.User? user,
    bool? isLoading,
    bool? isSaving,
    bool? isCheckingNickname,
    String? nicknameError,
    String? errorMessage,
    String? successMessage,
    String? nicknameDraft,
    File? imageDraft,
    bool? pushDraft,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isCheckingNickname: isCheckingNickname ?? this.isCheckingNickname,
      nicknameError: nicknameError,
      errorMessage: errorMessage,
      successMessage: successMessage,
      nicknameDraft: nicknameDraft ?? this.nicknameDraft,
      imageDraft: imageDraft,
      pushDraft: pushDraft,
    );
  }

  bool get hasDraftChanged {
    if (user == null) return false;
    final nickChanged =
        nicknameDraft.trim().isNotEmpty &&
        nicknameDraft.trim() != user!.nickname.trim();
    final imageChanged = imageDraft != null;
    final pushChanged =
        (pushDraft != null) && (pushDraft != user!.pushNotifications);
    return nickChanged || imageChanged || pushChanged;
  }

  bool get canSave {
    if (user == null) return false;
    if (isCheckingNickname || isSaving) return false;

    // 닉네임이 바뀌는 경우엔 비어있지 않아야 하고 에러가 없어야 함
    final nickWillChange =
        nicknameDraft.trim().isNotEmpty &&
        nicknameDraft.trim() != user!.nickname.trim();
    if (nickWillChange && (nicknameError != null)) return false;

    return hasDraftChanged;
  }
}

//ViewModel
class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase _getUserProfile;
  final UpdateUserProfileUseCase _updateUserProfile;
  final UpdateUserStatsUseCase _updateUserStats;
  final UploadProfileImageUseCase _uploadProfileImage;
  final CheckNicknameDuplicateUseCase _checkNicknameDuplicate;

  ProfileViewModel({
    required GetUserProfileUseCase getUserProfile,
    required UpdateUserProfileUseCase updateUserProfile,
    required UpdateUserStatsUseCase updateUserStats,
    required UploadProfileImageUseCase uploadProfileImage,
    required CheckNicknameDuplicateUseCase checkNicknameDuplicate,
  }) : _getUserProfile = getUserProfile,
       _updateUserProfile = updateUserProfile,
       _updateUserStats = updateUserStats,
       _uploadProfileImage = uploadProfileImage,
       _checkNicknameDuplicate = checkNicknameDuplicate,
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
      state = state.copyWith(
        isLoading: false,
        user: u,
        nicknameDraft: u.nickname,
        imageDraft: null,
        pushDraft: u.pushNotifications,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 닉네임 드래프트 변경 (UI 바인딩)
  void setNicknameDraft(String v) {
    // 길이/공백 등 간단 검증 (원하면 규칙 추가)
    if (v.trim().isEmpty) {
      state = state.copyWith(nicknameDraft: v, nicknameError: '닉네임을 입력해 주세요.');
      return;
    }
    state = state.copyWith(nicknameDraft: v, nicknameError: null);
  }

  // /// 푸시 알림 드래프트 토글
  // void setPushDraft(bool value) {
  //   state = state.copyWith(pushDraft: value);
  // }

  /// 새 이미지 파일 선택
  void setImageDraft(File? file) {
    state = state.copyWith(imageDraft: file);
  }

  /// 닉네임 중복 체크
  Future<bool> checkNicknameDuplicate() async {
    if (state.user == null) return false;

    final newName = state.nicknameDraft.trim();
    final currentName = state.user!.nickname.trim();

    // 동일 닉네임이면 중복아님
    if (newName == currentName) {
      state = state.copyWith(nicknameError: null);
      return true;
    }

    if (newName.isEmpty) {
      state = state.copyWith(nicknameError: '닉네임을 입력해 주세요.');
      return false;
    }

    try {
      state = state.copyWith(isCheckingNickname: true, nicknameError: null);
      final isDup = await _checkNicknameDuplicate.execute(newName);
      if (isDup) {
        state = state.copyWith(
          isCheckingNickname: false,
          nicknameError: '이미 사용 중인 닉네임입니다.',
        );
        return false;
      } else {
        state = state.copyWith(isCheckingNickname: false, nicknameError: null);
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isCheckingNickname: false,
        nicknameError: '닉네임 확인 중 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 프로필 저장 (닉네임/이미지/푸시옵션 변경 포함)
  Future<void> saveProfile() async {
    if (state.user == null) return;
    if (!state.canSave) return;

    try {
      state = state.copyWith(
        isSaving: true,
        errorMessage: null,
        successMessage: null,
      );

      final uid = state.user!.uid;

      // 1) 닉네임 변경 예정이면 먼저 중복체크
      final nickWillChange =
          state.nicknameDraft.trim().isNotEmpty &&
          state.nicknameDraft.trim() != state.user!.nickname.trim();
      if (nickWillChange) {
        final ok = await checkNicknameDuplicate();
        if (!ok) {
          state = state.copyWith(isSaving: false);
          return;
        }
      }

      // 2) 이미지 업로드 (드래프트가 있을 때만)
      String? newPhotoUrl = state.user!.profileImageUrl;
      if (state.imageDraft != null) {
        final url = await _uploadProfileImage.execute(uid, state.imageDraft!);
        newPhotoUrl = url;
      }

      // // 3) 푸시 설정 반영
      // final push = state.pushDraft ?? state.user!.pushNotifications;

      // 4) User 엔티티 업데이트
      final updated = state.user!.copyWith(
        nickname: state.nicknameDraft.trim(),
        profileImageUrl: newPhotoUrl,
        // pushNotifications: push,
        updatedAt: DateTime.now(), // 실제 저장은 DS에서 serverTimestamp, 엔티티는 표시용
      );

      await _updateUserProfile.execute(updated);

      // 5) 성공 반영 + 드래프트 초기화
      state = state.copyWith(
        isSaving: false,
        user: updated,
        imageDraft: null,
        successMessage: '프로필이 업데이트되었습니다.',
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
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

  /// 메시지 클리어 (Snackbar 이후)
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      nicknameError: null,
    );
  }
}
