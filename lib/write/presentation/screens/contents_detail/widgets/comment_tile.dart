import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

/// 단일 댓글의 UI를 구성하는 재사용 가능한 위젯입니다.
class CommentTile extends StatelessWidget {
  final String username;
  final String timestamp;
  final String comment;

  const CommentTile({
    super.key,
    required this.username,
    required this.timestamp,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 18, backgroundColor: AppColors.n100),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    username,
                    style: AppTypography.style(
                      AppTypography.s12,
                      weight: AppTypography.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(timestamp, style: AppTypography.caption(AppColors.n600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
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
