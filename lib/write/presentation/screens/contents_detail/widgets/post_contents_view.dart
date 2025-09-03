import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/post_actions.dart';
import 'package:flutter_sns/write/presentation/widgets/image_page_view.dart';
import 'package:intl/intl.dart';

/// 게시물의 제목, 내용, 이미지, 상호작용 버튼 등을 포함하는 위젯
class PostContentView extends StatelessWidget {
  final Posts post;
  const PostContentView({super.key, required this.post});

  /// DateTime 객체를 '몇 분 전'과 같은 상대 시간 문자열로 변환
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yy.MM.dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // TODO: 실제 태그 데이터로 교체 필요
    final tags = [
      post.category,
      post.mode == 'punch' ? '팩폭해줘' : '공감해줘',
    ].where((tag) => tag.isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 해시태그
          Row(
            children: tags
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '#$tag',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.n600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // 제목
          Text(post.title, style: AppTypography.h3(AppColors.n900)),
          const SizedBox(height: 16),

          // 작성자 정보
          Row(
            children: [
              // TODO: 실제 프로필 이미지 URL로 교체
              const CircleAvatar(radius: 12, backgroundColor: AppColors.n100),
              const SizedBox(width: 8),
              Text(
                post.author.nickname,
                style: textTheme.bodySmall?.copyWith(color: AppColors.n800),
              ),
              const Spacer(),
              Text(
                _formatTimeAgo(post.createdAt),
                style: AppTypography.caption(AppColors.n600),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 본문 내용
          Text(post.content, style: AppTypography.body(AppColors.n800)),
          const SizedBox(height: 24),

          // 이미지
          if (post.images.isNotEmpty)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: ImagePageView(imagePaths: post.images),
              ),
            ),
          const SizedBox(height: 16),

          // 좋아요 및 댓글 수
          PostActions(postId: post.id, likeCount: post.stats.likesCount),
        ],
      ),
    );
  }
}
