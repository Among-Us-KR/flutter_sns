import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comments_domain;
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/get_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_stats_usecase.dart';

// State
class ProfileState {
  final domain.User? user;

  // 내가 쓴 글, 좋아요 누른 글 목록
  final List<Posts> userPosts;
  final List<Posts> userLikedPosts;
  // '내가 댓글 단 글' 목록을 댓글 엔티티로 변경
  final Map<String, comments_domain.Comments> userComments;
  final Map<String, String> userCommentedPostTitles;

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.userPosts = const [],
    this.userLikedPosts = const [],
    this.userComments = const {},
    this.userCommentedPostTitles = const {},
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    domain.User? user,
    List<Posts>? userPosts,
    List<Posts>? userLikedPosts,
    Map<String, comments_domain.Comments>? userComments,
    Map<String, String>? userCommentedPostTitles,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      userPosts: userPosts ?? this.userPosts,
      userLikedPosts: userLikedPosts ?? this.userLikedPosts,
      userComments: userComments ?? this.userComments,
      userCommentedPostTitles:
          userCommentedPostTitles ?? this.userCommentedPostTitles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ViewModel
class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase _getUserProfile;
  final UpdateUserStatsUseCase _updateUserStats;
  final PostRepository _postRepository;

  ProfileViewModel({
    required GetUserProfileUseCase getUserProfile,
    required UpdateUserStatsUseCase updateUserStats,
    required PostRepository postRepository,
  }) : _getUserProfile = getUserProfile,
       _updateUserStats = updateUserStats,
       _postRepository = postRepository,
       super(const ProfileState());

  // ✅ 공통: 현재 로그인 UID 가져오기 (없으면 null 반환)
  String? _getCurrentUidOrNull() {
    return fa.FirebaseAuth.instance.currentUser?.uid;
  }

  // 현재 로그인 사용자 로드
  Future<void> loadCurrentUser() async {
    final uid = _getCurrentUidOrNull();
    if (uid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }
    await loadByUid(uid);
  }

  /// 특정 UID 로드 (타 사용자 프로필 조회 시)
  Future<void> loadByUid(String uid) async {
    final currentUid = _getCurrentUidOrNull();
    if (currentUid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      final u = await _getUserProfile.execute(uid);

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

  /// 사용자가 작성한 게시글을 불러옵니다.
  Future<void> loadUserPosts() async {
    final uid = _getCurrentUidOrNull();
    if (uid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }
    try {
      final posts = await _postRepository.getUserPosts(uid);
      state = state.copyWith(userPosts: posts);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 사용자가 좋아요를 누른 게시글을 불러옵니다.
  Future<void> loadUserLikedPosts() async {
    final uid = _getCurrentUidOrNull();
    if (uid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }
    try {
      final likedPosts = await _postRepository.getUserLikedPosts(uid);
      state = state.copyWith(userLikedPosts: likedPosts);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 사용자가 댓글을 단 댓글을 불러옵니다.
  Future<void> loadUserComments() async {
    final uid = _getCurrentUidOrNull();
    if (uid == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }
    try {
      final comments = await _postRepository.getUserComments(uid);
      final postTitles = <String, String>{};

      // 댓글 목록을 순회하며 각 댓글의 게시글 제목을 가져옴
      for (final comment in comments) {
        final post = await _postRepository.getPostById(comment.postId);
        if (post != null) {
          postTitles[comment.id] = post.title;
        }
      }

      // 댓글 목록과 게시글 제목을 함께 상태에 저장
      final commentsMap = {for (var item in comments) item.id: item};
      state = state.copyWith(
        userComments: commentsMap,
        userCommentedPostTitles: postTitles,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 메시지 클리어 (Snackbar 이후)
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
