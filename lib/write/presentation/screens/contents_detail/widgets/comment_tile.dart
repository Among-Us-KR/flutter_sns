import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart';
import 'package:intl/intl.dart';

class CommentTile extends StatelessWidget {
  final Comments comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: 실제 프로필 이미지 URL로 교체
        const CircleAvatar(radius: 18, backgroundColor: AppColors.n100),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.author.nickname,
                    style: AppTypography.style(
                      AppTypography.s12,
                      weight: AppTypography.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MM.dd HH:mm').format(comment.createdAt),
                    style: AppTypography.caption(AppColors.n600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: AppTypography.style(
                  AppTypography.s12,
                  color: AppColors.n700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
