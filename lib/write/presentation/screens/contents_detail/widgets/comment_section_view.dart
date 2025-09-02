import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'comment_tile.dart';

class CommentSectionView extends StatelessWidget {
  const CommentSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 2',
            style: AppTypography.style(
              AppTypography.s16,
              weight: AppTypography.medium,
              color: AppColors.n900,
            ),
          ),
          const SizedBox(height: 16),
          const CommentTile(
            username: '쌩나는햄스터',
            timestamp: '2025-08-28 15:30',
            comment: '댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당',
          ),
          const SizedBox(height: 16),
          const CommentTile(
            username: '웃긴거북이',
            timestamp: '2025-08-28 15:30',
            comment: '댓글내용입니당댓글내용입니당',
          ),
        ],
      ),
    );
  }
}
