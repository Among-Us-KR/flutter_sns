import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comments_domain;
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/get_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_stats_usecase.dart';

//State
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

//ViewModel
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
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 모든 프로필 관련 데이터를 병렬로 가져옵니다.
      final results = await Future.wait([
        _getUserProfile.execute(uid),
        _postRepository.getUserPosts(uid),
        _postRepository.getUserLikedPosts(uid),
        _loadUserCommentsAndPostTitles(uid), // 댓글과 게시글 제목을 함께 로드하는 헬퍼
      ]);

      // Future.wait가 성공적으로 완료되면, 모든 데이터가 준비된 것입니다.
      final userProfile = results[0] as domain.User;
      final userPosts = results[1] as List<Posts>;
      final userLikedPosts = results[2] as List<Posts>;
      final commentsData = results[3] as Map<String, dynamic>;

      // 모든 데이터를 한 번에 상태에 반영합니다.
      state = state.copyWith(
        isLoading: false,
        user: userProfile,
        userPosts: userPosts,
        userLikedPosts: userLikedPosts,
        userComments: commentsData['comments'],
        userCommentedPostTitles: commentsData['titles'],
      );
    } catch (e, st) {
      // 데이터 로딩 중 어느 한 곳에서라도 오류가 발생하면 여기서 처리됩니다.
      print('프로필 로딩 중 오류 발생: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '프로필 정보를 불러오는 데 실패했습니다.', // 사용자에게 보여줄 일관된 오류 메시지
      );
    }
  }

  // 댓글과 해당 댓글이 달린 게시물의 제목을 함께 가져오는 헬퍼 메서드
  Future<Map<String, dynamic>> _loadUserCommentsAndPostTitles(
    String uid,
  ) async {
    final comments = await _postRepository.getUserComments(uid);
    // 댓글이 달린 게시물 ID 목록 (중복 제거)
    final postIds = comments.map((c) => c.postId).toSet();
    // ID 목록으로 게시물 정보들을 한 번에 가져옵니다. (성능 개선)
    final postFutures = postIds.map(
      (postId) => _postRepository.getPostById(postId),
    );
    final posts = (await Future.wait(postFutures)).whereType<Posts>().toList();
    final postTitleMap = {for (var p in posts) p.id: p.title};

    return {
      'comments': {for (var c in comments) c.id: c},
      'titles': {
        for (var c in comments) c.id: postTitleMap[c.postId] ?? '삭제된 게시글',
      },
    };
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
