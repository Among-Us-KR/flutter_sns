import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/firestore_mapper.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/post_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/top_tab_bar.dart';

// 게시물 목록 스트림을 제공하는 프로바이더
final postsStreamProvider = StreamProvider<List<Posts>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => postFromFirestore(doc)).toList();
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
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(postsStreamProvider.future),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                            child: Text('아직 게시물이 없어요. 첫 글을 작성해보세요!'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(postsStreamProvider.future),
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: controller,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostView(post: post);
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                print('게시물을 불러오는 중 에러 발생: $error');
                print(stackTrace);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(postsStreamProvider.future),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: Text('데이터를 불러오는 데 실패했습니다.\n$error'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
