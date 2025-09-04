import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart';
import 'package:intl/intl.dart';

class CommentTile extends StatelessWidget {
  final Comments comment;

  const CommentTile({super.key, required this.comment});

  /// DateTime 객체를 '몇 분 전'과 같은 상대 시간 문자열로 변환합니다.
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 댓글 작성자의 프로필 이미지를 표시
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.n100,
          backgroundImage: comment.author.profileImageUrl != null
              ? NetworkImage(comment.author.profileImageUrl!)
              : null,
          child: comment.author.profileImageUrl == null
              ? const Icon(Icons.person, size: 20, color: AppColors.n400)
              : null,
        ),
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
                    _formatTimeAgo(comment.createdAt),
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
