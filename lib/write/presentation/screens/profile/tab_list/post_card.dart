import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

// 내가 쓴 글 / 좋아요 누른 글 아이템
class PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final String mode; // 'punch' or 'empathy'
  final String? imageUrl;
  final String date;
  final int commentCount;

  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.category,
    required this.mode,
    this.imageUrl,
    required this.date,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
              _buildHashtag(context, '#$category'),
              SizedBox(width: 3),
              _buildHashtag(context, mode == 'punch' ? '#팩폭해줘' : '#공감해줘'),
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
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      content,
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
                _buildThumbnail(context),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // 하단 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.n600,
                ),
              ),
              Text(
                '댓글 $commentCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.n600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHashtag(BuildContext context, String tag) {
    final theme = Theme.of(context);

    return Text(
      tag,
      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.n600),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
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
        child: Image.asset(
          imageUrl!,
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
