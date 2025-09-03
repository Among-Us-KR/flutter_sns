import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

// ProfileEditState는 기존과 동일
class ProfileEditState {
  final String nickname;
  final File? profileImageFile;
  final String? profileImageUrl;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isNicknameDuplicate;

  ProfileEditState({
    required this.nickname,
    this.profileImageFile,
    this.profileImageUrl,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isNicknameDuplicate = false,
  });

  ProfileEditState copyWith({
    String? nickname,
    File? profileImageFile,
    String? profileImageUrl,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isNicknameDuplicate,
  }) {
    return ProfileEditState(
      nickname: nickname ?? this.nickname,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isNicknameDuplicate: isNicknameDuplicate ?? this.isNicknameDuplicate,
    );
  }
}

// StateNotifierProvider도 기존과 동일
final profileEditViewModelProvider =
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      final userId = ref.watch(currentUserIdProvider);
      return ProfileEditViewModel(userRepository, userId);
    });

// ProfileEditViewModel 클래스
class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final UserRepository _userRepository;
  final String _currentUserId;
  Timer? _nicknameCheckDebounce;

  ProfileEditViewModel(this._userRepository, this._currentUserId)
    : super(ProfileEditState(nickname: '')) {
    // 뷰모델 생성 시 프로필 정보를 자동으로 로드합니다.
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    print('DEBUG: 프로필 정보 로드 시작');
    state = state.copyWith(isLoading: true);
    try {
      final user = await _userRepository.getUserProfile(_currentUserId);
      print(
        'DEBUG: 프로필 로드 성공 - 닉네임: ${user.nickname}, 이미지 URL: ${user.profileImageUrl}',
      );
      state = state.copyWith(
        nickname: user.nickname,
        profileImageUrl: user.profileImageUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '프로필 정보를 불러오는데 실패했습니다: ${e.toString()}',
      );
    }
  }

  void updateNickname(String newNickname) {
    if (state.nickname == newNickname) return;

    state = state.copyWith(nickname: newNickname, isNicknameDuplicate: false);

    _nicknameCheckDebounce?.cancel();
    _nicknameCheckDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final isDuplicate = await _userRepository.isNicknameDuplicate(
          newNickname,
        );
        state = state.copyWith(isNicknameDuplicate: isDuplicate);
      } catch (e) {
        state = state.copyWith(errorMessage: '닉네임 중복 확인 실패: ${e.toString()}');
      }
    });
  }

  void setProfileImage(File imageFile) {
    print('DEBUG: 이미지 파일 선택됨 - 경로: ${imageFile.path}');
    state = state.copyWith(profileImageFile: imageFile, profileImageUrl: null);
    print(
      'DEBUG: 뷰모델 상태 업데이트 - profileImageFile: ${state.profileImageFile != null}',
    );
  }

  // lib/write/presentation/screens/profile/profile_edit_view_model.dart

  Future<bool> saveProfile() async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      String? finalImageUrl = state.profileImageUrl;
      print(
        'DEBUG: saveProfile 시작 - profileImageFile: ${state.profileImageFile != null}',
      );

      // 1. Check if a new profile image file has been selected.
      if (state.profileImageFile != null) {
        print('DEBUG: 새로운 프로필 이미지 파일을 업로드합니다.');
        finalImageUrl = await _userRepository.uploadProfileImage(
          _currentUserId,
          state.profileImageFile!,
        );
        print('DEBUG: 이미지 업로드 성공, URL: $finalImageUrl');
      } else {
        print('DEBUG: 새로운 이미지 파일이 선택되지 않았습니다. 기존 URL 사용.');
      }

      // 2. Prepare the user model for updating.
      final userProfile = await _userRepository.getUserProfile(_currentUserId);
      final updatedUser = userProfile.copyWith(
        nickname: state.nickname,
        profileImageUrl: finalImageUrl,
      );

      // 3. Update the user profile in Firestore.
      await _userRepository.updateUserProfile(updatedUser);

      state = state.copyWith(
        isSaving: false,
        errorMessage: null,
        profileImageFile: null,
        profileImageUrl: finalImageUrl,
      );

      return true; // Return true on success
    } catch (e, stacktrace) {
      print('DEBUG: 프로필 저장 실패: $e');
      print('DEBUG: 스택 트레이스: $stacktrace');
      state = state.copyWith(
        isSaving: false,
        errorMessage: '프로필 저장 실패: ${e.toString()}',
      );
      return false; // Return false on error
    }
  }
}
