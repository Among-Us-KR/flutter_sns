import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/post_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/top_tab_bar.dart';

// Firestore 데이터를 Posts 엔티티로 변환하는 헬퍼 함수
Posts _postFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  if (data == null) {
    throw StateError('Missing data for post ${doc.id}');
  }

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
    authorId: data['authorId'] as String? ?? '',
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

// 게시물 목록 스트림을 제공하는 프로바이더
final postsStreamProvider = StreamProvider<List<Posts>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => _postFromFirestore(doc)).toList();
      });
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController controller = PageController();
    final postsAsyncValue = ref.watch(postsStreamProvider);

    // SafeArea로 전체 화면을 감싸서 시스템 UI(상태 표시줄 등)와의 충돌을 방지합니다.
    return SafeArea(
      child: Column(
        children: [
          // 1. 상단 탭바
          const TopTabBar(),
          // -----------------
          // 2. 메인 콘텐츠 (이미지 피드)
          // -----------------
          // Expanded를 사용하여 PageView가 남은 공간을 모두 차지하도록 합니다.
          Expanded(
            child: postsAsyncValue.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('아직 게시물이 없어요. 첫 글을 작성해보세요!'));
                }
                return ScrollConfiguration(
                  behavior: NoGlowScrollBehavior(),
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: controller,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostView(
                        postId: post.id,
                        imagePaths: post.images,
                        username: post.author.nickname,
                        caption: post.content,
                        likeCount: post.stats.likesCount,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                print('게시물을 불러오는 중 에러 발생: $error');
                print(stackTrace);
                return Center(child: Text('데이터를 불러오는 데 실패했습니다.\n$error'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
