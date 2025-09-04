import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart';
import 'package:intl/intl.dart';

// 내가 댓글 단 글 아이템
class CommentCard extends StatelessWidget {
  final Comments comment;
  final String postTitle;
  final VoidCallback? onTap;

  const CommentCard({
    super.key,
    required this.comment,
    required this.postTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.n600,
              ),
            ),
            const SizedBox(height: 8),

            // 댓글 내용
            Text(
              comment.content,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 원글 제목
            Text(
              '원글: $postTitle',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.n600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
