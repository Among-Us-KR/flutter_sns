import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart';
import 'comment_tile.dart';

class CommentSectionView extends StatelessWidget {
  final List<Comments> comments;
  const CommentSectionView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SizedBox.shrink(); // 댓글이 없으면 아무것도 표시하지 않음
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${comments.length}',
            style: AppTypography.style(
              AppTypography.s16,
              weight: AppTypography.medium,
              color: AppColors.n900,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true, // ListView가 Column 내에서 자신의 크기만큼만 차지하도록
            physics: const NeverScrollableScrollPhysics(), // 부모 스크롤 사용
            itemCount: comments.length,
            itemBuilder: (context, index) =>
                CommentTile(comment: comments[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
