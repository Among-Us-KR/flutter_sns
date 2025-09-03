import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/post_actions.dart';

/// 게시물의 제목, 내용, 이미지, 상호작용 버튼 등을 포함하는 위젯입니다.
class PostContentView extends StatelessWidget {
  const PostContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 해시태그
          Row(
            children: [
              Text(
                '#대박스',
                style: textTheme.labelMedium?.copyWith(color: AppColors.n600),
              ),
              const SizedBox(width: 8),
              Text(
                '#공감해줘',
                style: textTheme.labelMedium?.copyWith(color: AppColors.brand),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 제목
          Text(
            '타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀..',
            style: AppTypography.h3(AppColors.n900),
          ),
          const SizedBox(height: 16),

          // 작성자 정보
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: AppColors.n100),
              const SizedBox(width: 8),
              Text(
                '화난강쥐',
                style: textTheme.bodySmall?.copyWith(color: AppColors.n800),
              ),
              const Spacer(),
              Text('25분 전', style: AppTypography.caption(AppColors.n600)),
            ],
          ),
          const SizedBox(height: 24),

          // 본문 내용
          Text(
            '내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용',
            style: AppTypography.body(AppColors.n800),
          ),
          const SizedBox(height: 24),

          // 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              'assets/images/cat_image.jpeg',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 16),

          // 좋아요 및 댓글 수 위젯
          const PostActions(likeCount: 20, commentCount: 2),
        ],
      ),
    );
  }
}
