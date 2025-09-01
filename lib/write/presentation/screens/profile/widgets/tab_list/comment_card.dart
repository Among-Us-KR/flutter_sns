import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

// 내가 댓글 단 글 아이템
class CommentCard extends StatelessWidget {
  final String content;
  final String postTitle;
  final String date;

  const CommentCard({
    super.key,
    required this.content,
    required this.postTitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜
          Text(
            date,
            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.n600),
          ),
          const SizedBox(height: 8),

          // 댓글 내용
          Text(
            content,
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
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.n600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
