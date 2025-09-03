import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sns/write/presentation/widgets/image_page_view.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/contents_detail_page.dart';

class PostView extends StatelessWidget {
  final Posts post;

  const PostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImagePageView(imagePaths: post.images),
        // 이미지 위에 UI를 올리기 위한 그래디언트 오버레이
        // IgnorePointer를 사용하여 이 위젯이 터치 이벤트를 가로채지 않도록 함
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.4),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        // UI 컴포넌트 (좋아요 버튼, 정보)
        Positioned(
          right: 16,
          bottom: 160,
          child: _LikeButton(
            postId: post.id,
            initialLikeCount: post.stats.likesCount,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: _PostInfo(
            postId: post.id,
            username: post.author.nickname,
            caption: post.content,
            createdAt: post.createdAt,
            commentCount: post.stats.commentsCount,
          ),
        ),
      ],
    );
  }
}

// --- PostItem 내부에서만 사용하는 위젯들 (Private Widgets) ---

// 좋아요 버튼 위젯
class _LikeButton extends ConsumerWidget {
  final String postId;
  final int initialLikeCount;
  const _LikeButton({required this.postId, required this.initialLikeCount});

  void _toggleLike(WidgetRef ref) {
    ref.read(postInteractionServiceProvider).toggleLike(postId: postId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isLikedAsyncValue = ref.watch(isPostLikedProvider(postId));
    final likeCountAsyncValue = ref.watch(postLikesCountProvider(postId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: isLikedAsyncValue.when(
            data: (isLiked) => Image.asset(
              isLiked
                  ? 'assets/icons/heart_white.png'
                  : 'assets/icons/heart_white_empty.png',
              width: 32,
              height: 32,
            ),
            loading: () => Image.asset(
              'assets/icons/heart_white_empty.png',
              width: 32,
              height: 32,
            ),
            error: (err, stack) => const Icon(Icons.error, color: Colors.white),
          ),
          onPressed: () => _toggleLike(ref),
        ),
        likeCountAsyncValue.when(
          data: (count) => Text(
            '$count',
            style: textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
          loading: () => Text(
            '$initialLikeCount',
            style: textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
          error: (err, stack) => Text(
            '!',
            style: textTheme.labelLarge?.copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

// 하단 정보 위젯
class _PostInfo extends StatelessWidget {
  final String postId;
  final String username;
  final String caption;
  final DateTime createdAt;
  final int commentCount;

  const _PostInfo({
    required this.postId,
    required this.username,
    required this.caption,
    required this.createdAt,
    required this.commentCount,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('yy.MM.dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    const whiteColor = Colors.white;

    // GestureDetector로 감싸서 탭 이벤트를 감지하고, 탭하면 게시물 상세 페이지로 이동
    return GestureDetector(
      onTap: () => context.go('/post/$postId'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 8, backgroundColor: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  username,
                  style: AppTypography.style(
                    AppTypography.s12,
                    weight: AppTypography.bold,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeAgo(createdAt),
                  style: AppTypography.caption(whiteColor.withOpacity(0.8)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(whiteColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // TODO: 실제 태그 데이터 표시
                Text('#대박스', style: AppTypography.labelXS(whiteColor)),
                const SizedBox(width: 8),
                Text('#공감해줘', style: AppTypography.labelXS(whiteColor)),
                const Spacer(),
                Text(
                  '댓글 $commentCount',
                  style: AppTypography.labelXS(whiteColor.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
