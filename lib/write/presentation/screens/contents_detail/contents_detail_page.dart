import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/utils/xss.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comment_entity;
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/providers/post_detail_providers.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_input.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_section_view.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/post_contents_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page.dart';

class ContentsDetailPage extends ConsumerWidget {
  const ContentsDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(postProvider(postId));
    // `commentsProvider`는 `post_detail_providers.dart`에 정의되어 있습니다.
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
              // 수정된 부분: postAsyncValue를 직접 전달
              _showMoreOptions(context, ref, postAsyncValue);
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
              // 1. 게시물 본문 위젯 (댓글 수는 PostActions 위젯 내부에서 실시간으로 가져옵니다)
              PostContentView(post: post),
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
  void _showMoreOptions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Posts> postAsyncValue,
  ) {
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
                  Navigator.pop(bottomSheetContext);

                  // AsyncValue에서 데이터를 안전하게 가져오기
                  final post = postAsyncValue.asData?.value;

                  if (post != null) {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;

                    if (post.authorId == currentUserId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WritePage(postId: post.id),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('자신이 작성한 게시글만 편집할 수 있습니다.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게시물 정보를 불러올 수 없습니다.')),
                    );
                  }
                },
              ),
              ListTile(
                title: Text('삭제하기', style: textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmationDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 게시물 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
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
                final post = ref.read(postProvider(postId)).asData?.value;
                if (post == null) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('게시물 정보를 불러올 수 없습니다.')),
                  );
                  return;
                }

                // `writeViewModelProvider`는 `write_page_provider.dart`에 정의되어 있습니다.
                final viewModel = ref.read(writeViewModelProvider.notifier);
                viewModel.deletePost(post.id);

                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
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
