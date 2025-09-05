import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';

// 내가 쓴 글 / 좋아요 누른 글 아이템
class PostCard extends StatelessWidget {
  final Posts post;
  final VoidCallback? onTap; // ✅ onTap 콜백 함수 추가

  const PostCard({
    super.key,
    required this.post,
    this.onTap, // ✅ onTap 매개변수 추가
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String? imageUrl = post.images.isNotEmpty ? post.images.first : null;

    // InkWell로 전체 컨테이너를 감싸서 탭 이벤트를 처리합니다.
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorScheme.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 해시태그 (카테고리 + 모드)
            Row(
              children: [
                _buildHashtag(context, post.category),
                const SizedBox(width: 3),
                _buildHashtag(context, post.mode),
              ],
            ),

            // 게시글 내용
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        post.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(context, imageUrl),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // 하단 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(post.createdAt),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.n600,
                  ),
                ),
                Text(
                  '댓글 ${post.stats.commentsCount}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.n600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtag(BuildContext context, String tag) {
    final theme = Theme.of(context);
    String displayTag;

    // 모드 태그는 '팩폭' 또는 '공감'으로 표시
    if (tag == 'punch') {
      displayTag = '#팩폭해줘';
    } else if (tag == 'empathy') {
      displayTag = '#공감해줘';
    } else {
      displayTag = '#$tag';
    }

    return Text(
      displayTag,
      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.n600),
    );
  }

  Widget _buildThumbnail(BuildContext context, String imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colorScheme.surfaceContainerHigh,
              child: Icon(
                Icons.image,
                color: colorScheme.onSurfaceVariant,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}
