// // Post, Comment 엔티티와 리포지토리 유스케이스도 추가해야 합니다.
// // '내 글', '내 댓글', '내 공감' 탭 구현을 위해 필요

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_sns/write/domain/entities/users.dart' as entity;
// import 'package:flutter_sns/write/domain/usecases/get_user_profile_usecase.dart';
// import 'package:flutter_sns/write/domain/usecases/update_user_profile_usecase.dart';
// import 'package:flutter_sns/write/domain/usecases/upload_profile_image_usecase.dart';

// // 탭 종류를 정의하는 enum
// enum ProfileTab { posts, comments, likes }

// // 뷰모델의 상태
// class ProfileState {
//   final entity.User? user;
//   final bool isLoading;
//   final String? errorMessage;
//   final bool isProfileUpdating;
//   final String? successMessage;
//   final bool isNicknameChecking;
//   final bool isNicknameDuplicate;
//   final List<Post> posts;
//   final List<Comment> comments;
//   final List<Post> likedPosts;
//   final ProfileTab selectedTab;

//   const ProfileState({
//     this.user,
//     this.isLoading = false,
//     this.errorMessage,
//     this.isProfileUpdating = false,
//     this.successMessage,
//     this.isNicknameChecking = false,
//     this.isNicknameDuplicate = false,
//     this.posts = const [],
//     this.comments = const [],
//     this.likedPosts = const [],
//     this.selectedTab = ProfileTab.posts,
//   });

//   ProfileState copyWith({
//     entity.User? user,
//     bool? isLoading,
//     String? errorMessage,
//     bool? isProfileUpdating,
//     String? successMessage,
//     bool? isNicknameChecking,
//     bool? isNicknameDuplicate,
//     List<Post>? posts,
//     List<Comment>? comments,
//     List<Post>? likedPosts,
//     ProfileTab? selectedTab,
//   }) {
//     return ProfileState(
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage,
//       isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
//       successMessage: successMessage,
//       isNicknameChecking: isNicknameChecking ?? this.isNicknameChecking,
//       isNicknameDuplicate: isNicknameDuplicate ?? this.isNicknameDuplicate,
//       posts: posts ?? this.posts,
//       comments: comments ?? this.comments,
//       likedPosts: likedPosts ?? this.likedPosts,
//       selectedTab: selectedTab ?? this.selectedTab,
//     );
//   }
// }

// class ProfileViewModel extends StateNotifier<ProfileState> {
//   final GetUserProfileUseCase _getUserProfileUseCase;
//   final UpdateUserProfileUseCase _updateUserProfileUseCase;
//   final UploadProfileImageUseCase _uploadProfileImageUseCase;
//   final CheckNicknameDuplicateUseCase _checkNicknameDuplicateUseCase;

//   ProfileViewModel({
//     required GetUserProfileUseCase getUserProfileUseCase,
//     required UpdateUserProfileUseCase updateUserProfileUseCase,
//     required UploadProfileImageUseCase uploadProfileImageUseCase,
//     required CheckNicknameDuplicateUseCase checkNicknameDuplicateUseCase,
//   }) : _getUserProfileUseCase = getUserProfileUseCase,
//        _updateUserProfileUseCase = updateUserProfileUseCase,
//        _uploadProfileImageUseCase = uploadProfileImageUseCase,
//        _checkNicknameDuplicateUseCase = checkNicknameDuplicateUseCase,
//        super(const ProfileState());

//   // 1. 프로필 정보 로드
//   Future<void> loadUserProfile() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) {
//       state = state.copyWith(errorMessage: '로그인 정보가 없습니다.');
//       return;
//     }
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final user = await _getUserProfileUseCase.execute(uid);
//       state = state.copyWith(user: user, isLoading: false);
//       // '내 글', '내 댓글', '내 공감' 데이터도 여기서 로드해야 합니다.
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: '프로필 로딩 실패: ${e.toString()}',
//       );
//     }
//   }

//   // 2. 프로필 이미지 업데이트
//   Future<void> updateProfileImage(File imageFile) async {
//     final user = state.user;
//     if (user == null) {
//       state = state.copyWith(errorMessage: '사용자 정보가 없습니다.');
//       return;
//     }
//     state = state.copyWith(isProfileUpdating: true, errorMessage: null);
//     try {
//       final imageUrl = await _uploadProfileImageUseCase.execute(
//         user.uid,
//         imageFile.path,
//       );

//       // 이미지 URL이 업데이트된 새로운 유저 엔티티 생성
//       final updatedUser = user.copyWith(profileImageUrl: imageUrl);

//       // 업데이트된 엔티티를 유스케이스로 전달
//       await _updateUserProfileUseCase.execute(updatedUser);

//       state = state.copyWith(
//         user: updatedUser,
//         isProfileUpdating: false,
//         successMessage: '프로필 이미지가 성공적으로 변경되었습니다.',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isProfileUpdating: false,
//         errorMessage: '이미지 업로드 실패: ${e.toString()}',
//       );
//     }
//   }

//   // 3. 닉네임 중복 체크
//   Future<void> checkNicknameDuplicate(String nickname) async {
//     if (nickname.isEmpty) {
//       state = state.copyWith(
//         isNicknameChecking: false,
//         isNicknameDuplicate: false,
//       );
//       return;
//     }
//     state = state.copyWith(isNicknameChecking: true);
//     try {
//       final isDuplicate = await _checkNicknameDuplicateUseCase.execute(
//         nickname,
//       );
//       state = state.copyWith(
//         isNicknameChecking: false,
//         isNicknameDuplicate: isDuplicate,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isNicknameChecking: false,
//         errorMessage: '닉네임 중복 확인 실패: ${e.toString()}',
//       );
//     }
//   }

//   // 4. 프로필 정보 저장
//   Future<void> saveProfile({required String nickname}) async {
//     final user = state.user;
//     if (user == null) {
//       state = state.copyWith(errorMessage: '사용자 정보가 없습니다.');
//       return;
//     }
//     state = state.copyWith(isProfileUpdating: true, errorMessage: null);
//     try {
//       // 닉네임만 변경하는 경우를 처리
//       final updatedUser = user.copyWith(nickname: nickname);
//       await _updateUserProfileUseCase.execute(updatedUser);

//       state = state.copyWith(
//         user: updatedUser,
//         isProfileUpdating: false,
//         successMessage: '프로필 정보가 성공적으로 저장되었습니다.',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isProfileUpdating: false,
//         errorMessage: '프로필 저장 실패: ${e.toString()}',
//       );
//     }
//   }

//   // 5. 탭 변경 핸들러
//   void selectTab(int index) {
//     state = state.copyWith(selectedTab: ProfileTab.values[index]);
//   }

//   void clearMessage() {
//     state = state.copyWith(errorMessage: null, successMessage: null);
//   }
// }

// final profileViewModelProvider =
//     StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
//       final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
//       final updateUserProfileUseCase = ref.read(
//         updateUserProfileUseCaseProvider,
//       );
//       final uploadProfileImageUseCase = ref.read(
//         uploadProfileImageUseCaseProvider,
//       );
//       final checkNicknameDuplicateUseCase = ref.read(
//         checkNicknameDuplicateUseCaseProvider,
//       );

//       return ProfileViewModel(
//         getUserProfileUseCase: getUserProfileUseCase,
//         updateUserProfileUseCase: updateUserProfileUseCase,
//         uploadProfileImageUseCase: uploadProfileImageUseCase,
//         checkNicknameDuplicateUseCase: checkNicknameDuplicateUseCase,
//       );
//     });
