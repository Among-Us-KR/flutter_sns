import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/providers/post_interaction_providers.dart';

// 좋아요 버튼 위젯
class LikeButton extends ConsumerWidget {
  final String postId;
  final int initialLikeCount;
  const LikeButton({
    super.key,
    required this.postId,
    required this.initialLikeCount,
  });

  void _toggleLike(WidgetRef ref) {
    ref.read(postInteractionServiceProvider).toggleLike(postId: postId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isLikedAsyncValue = ref.watch(isPostLikedProvider(postId));
    final likeCountAsyncValue = ref.watch(postLikesCountProvider(postId));

    final isLiked = isLikedAsyncValue.valueOrNull ?? false;
    final likeCountColor = isLiked ? AppColors.brand : AppColors.n100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: isLikedAsyncValue.when(
            data: (isLiked) => Image.asset(
              isLiked
                  ? 'assets/icons/heart_orange.png'
                  : 'assets/icons/heart_white_empty.png',
              width: 32,
              height: 32,
            ),
            loading: () => Image.asset(
              'assets/icons/heart_white_empty.png',
              width: 32,
              height: 32,
            ),
            error: (err, stack) => const Icon(Icons.error, color: Colors.white),
          ),
          onPressed: () => _toggleLike(ref),
        ),
        likeCountAsyncValue.when(
          data: (count) => Text(
            '$count',
            style: textTheme.labelLarge?.copyWith(color: likeCountColor),
          ),
          loading: () => Text(
            '$initialLikeCount',
            style: textTheme.labelLarge?.copyWith(color: likeCountColor),
          ),
          error: (err, stack) => Text(
            '!',
            style: textTheme.labelLarge?.copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
