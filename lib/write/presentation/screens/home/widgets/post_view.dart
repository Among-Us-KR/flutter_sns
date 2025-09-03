import 'package:flutter/material.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/widgets/image_page_view.dart';

import 'like_button.dart';
import 'post_info.dart';

class PostView extends StatelessWidget {
  final Posts post;

  const PostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImagePageView(imagePaths: post.images),
        // 이미지 위에 UI를 올리기 위한 그래디언트 오버레이
        // IgnorePointer를 사용하여 이 위젯이 터치 이벤트를 가로채지 않도록 함
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.4),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        // UI 컴포넌트 (좋아요 버튼, 정보)
        Positioned(
          right: 16,
          bottom: 160,
          child: LikeButton(
            postId: post.id,
            initialLikeCount: post.stats.likesCount,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: PostInfo(
            postId: post.id,
            username: post.author.nickname,
            caption: post.content,
            createdAt: post.createdAt,
            commentCount: post.stats.commentsCount,
          ),
        ),
      ],
    );
  }
}
