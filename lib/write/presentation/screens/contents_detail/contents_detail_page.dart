import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/utils/xss.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comment_entity;
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_input.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/post_contents_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_section_view.dart';

// --- Providers and Helper Functions ---

// Firestore 데이터를 Posts 엔티티로 변환하는 헬퍼 함수
Posts _postFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  if (data == null) throw StateError('Missing data for post ${doc.id}');

  // 중첩된 author 객체 처리
  final authorData = data['author'];
  final authorMap = (authorData is Map)
      ? Map<String, dynamic>.from(authorData)
      : <String, dynamic>{};
  final author = Author(
    nickname: authorMap['nickname'] as String? ?? 'Unknown User',
    profileImageUrl: authorMap['profileImageUrl'] as String?,
  );

  // 중첩된 stats 객체 처리
  final statsData = data['stats'];
  final statsMap = (statsData is Map)
      ? Map<String, dynamic>.from(statsData)
      : <String, dynamic>{};
  final stats = PostStats(
    likesCount: statsMap['likesCount'] as int? ?? 0,
    commentsCount: statsMap['commentsCount'] as int? ?? 0,
  );

  // 이미지 리스트 처리
  final imagesData = data['images'];
  final images = (imagesData is List)
      ? imagesData.map((item) => item.toString()).toList()
      : <String>[];

  // 타임스탬프 처리
  final createdAtData = data['createdAt'];
  final updatedAtData = data['updatedAt'];
  final createdAt = (createdAtData is Timestamp)
      ? createdAtData.toDate()
      : DateTime.now();
  final updatedAt = (updatedAtData is Timestamp)
      ? updatedAtData.toDate()
      : DateTime.now();

  return Posts(
    id: doc.id,
    authorId: data['userId'] as String? ?? '',
    author: author,
    category: data['category'] as String? ?? '',
    mode: data['mode'] as String? ?? '',
    title: data['title'] as String? ?? '',
    content: data['content'] as String? ?? '',
    images: images,
    stats: stats,
    createdAt: createdAt,
    updatedAt: updatedAt,
    reportCount: data['reportCount'] as int? ?? 0,
  );
}

// Firestore 데이터를 Comments 엔티티로 변환하는 헬퍼 함수
comment_entity.Comments _commentFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  if (data == null) throw StateError('Missing data for comment ${doc.id}');

  // 중첩된 author 객체 처리 (더 안전하게)
  final authorData = data['author'];
  final authorMap = (authorData is Map)
      ? Map<String, dynamic>.from(authorData)
      : <String, dynamic>{};
  final author = comment_entity.Author(
    nickname: authorMap['nickname'] as String? ?? 'Unknown User',
    profileImageUrl: authorMap['profileImageUrl'] as String?,
  );

  // 타임스탬프 처리
  final createdAtData = data['createdAt'];
  final updatedAtData = data['updatedAt'];
  final createdAt = (createdAtData is Timestamp)
      ? createdAtData.toDate()
      : DateTime.now();
  final updatedAt = (updatedAtData is Timestamp)
      ? updatedAtData.toDate()
      : DateTime.now();

  // reportCount 처리
  final reportCountData = data['reportCount'];
  final reportCount = (reportCountData is num) ? reportCountData.toInt() : 0;

  return comment_entity.Comments(
    id: doc.id,
    postId: data['postId'] as String? ?? '',
    authorId: data['userId'] as String? ?? '',
    author: author,
    content: data['content'] as String? ?? '',
    createdAt: createdAt,
    updatedAt: updatedAt,
    reportCount: reportCount,
  );
}

// 특정 게시물 하나의 스트림을 제공하는 프로바이더
final postProvider = StreamProvider.family<Posts, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map(_postFromFirestore);
});

// 특정 게시물의 댓글 목록 스트림을 제공하는 프로바이더
final commentsProvider =
    StreamProvider.family<List<comment_entity.Comments>, String>((ref, postId) {
      return FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_commentFromFirestore).toList());
    });

// --- Service and Provider for adding comments ---

class CommentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommentService(this._firestore, this._auth);

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final sanitizedContent = XssFilter.sanitize(content);
    if (sanitizedContent.isEmpty) {
      throw Exception('댓글 내용을 입력해주세요.');
    }

    // Firestore에서 현재 사용자의 닉네임과 프로필 이미지 URL 가져오기
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userData = userDoc.data();
    final nickname = userData?['nickname'] as String? ?? '이름없음';
    final profileImageUrl = userData?['profileImageUrl'] as String?;

    final newCommentRef = _firestore.collection('comments').doc();
    final postRef = _firestore.collection('posts').doc(postId);

    final commentData = {
      'postId': postId,
      'userId': currentUser.uid,
      'author': {'nickname': nickname, 'profileImageUrl': profileImageUrl},
      'content': sanitizedContent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'reportCount': 0,
    };

    // Firestore 보안 규칙에 따라, 다른 사람의 게시물('posts' 문서)을 수정할 권한이 없습니다.
    // 따라서 댓글을 추가할 때 게시물의 댓글 수를 직접 업데이트하는 로직을 제거하고,
    // 'comments' 컬렉션에 새 댓글을 추가하는 작업만 수행합니다.
    // 게시물의 댓글 수를 실시간으로 정확하게 반영하려면 서버 측 로직(예: Cloud Function)을 사용해야 합니다.
    await newCommentRef.set(commentData);
  }
}

final commentServiceProvider = Provider((ref) {
  return CommentService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class ContentsDetailPage extends ConsumerWidget {
  const ContentsDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(postProvider(postId));
    final commentsAsyncValue = ref.watch(commentsProvider(postId));

    return Scaffold(
      appBar: AppBar(
        // 스크롤 시 앱바 색상이 변하는 것을 방지
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        // 데이터 로딩 상태에 따라 제목을 다르게 표시
        title: postAsyncValue.when(
          data: (post) => Text(
            post.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          loading: () => const Text(''),
          error: (_, __) => const Text('오류'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      // ScrollConfiguration을 사용하여 스크롤 시 파란색 Glow 효과를 제거
      body: postAsyncValue.when(
        data: (post) => ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: ListView(
            children: [
              // 1. 게시물 본문 위젯
              PostContentView(
                post: post,
                commentCount: commentsAsyncValue.asData?.value.length,
              ),
              // 2. 구분선
              const Divider(height: 1, thickness: 1, color: AppColors.n300),
              // 3. 댓글 목록 위젯
              _buildCommentSection(commentsAsyncValue),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('게시물 로딩 에러: $error');
          print(stack);
          return Center(child: Text('게시물을 불러올 수 없습니다: $error'));
        },
      ),
      // 4. 하단 댓글 입력창 위젯
      bottomNavigationBar: CommentInputField(postId: postId),
    );
  }

  Widget _buildCommentSection(
    AsyncValue<List<comment_entity.Comments>> commentsAsyncValue,
  ) {
    return commentsAsyncValue.when(
      data: (comments) => CommentSectionView(comments: comments),
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        print('댓글 로딩 에러: $error');
        print(stack);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('댓글 로딩 실패: $error'),
        );
      },
    );
  }

  /// 점 세개 아이콘을 눌렀을 때 표시되는 하단 메뉴(Bottom Sheet)
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext bottomSheetContext) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: Text(
                  '편집하기',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.brand),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext); // 바텀 시트 닫기
                  // TODO: 편집 페이지로 이동하는 로직 구현
                },
              ),
              ListTile(
                title: Text('삭제하기', style: textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(bottomSheetContext); // 바텀 시트 닫기
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 게시물 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            '정말로 삭제하시겠습니까?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '이 게시물을 삭제하면 복원할 수 없습니다.',
            style: AppTypography.body(AppColors.n600),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소', style: TextStyle(color: AppColors.n900)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // TODO: 실제 게시물 삭제 로직 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.n900,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
