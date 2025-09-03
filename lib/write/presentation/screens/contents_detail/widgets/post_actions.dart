import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/providers/post_interaction_providers.dart';

class PostActions extends ConsumerWidget {
  final String postId;
  final int likeCount;

  const PostActions({super.key, required this.postId, required this.likeCount});

  void _toggleLike(WidgetRef ref) {
    ref.read(postInteractionServiceProvider).toggleLike(postId: postId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isLikedAsyncValue = ref.watch(isPostLikedProvider(postId));
    final likeCountAsyncValue = ref.watch(postLikesCountProvider(postId));
    final commentsCountAsync = ref.watch(commentsCountProvider(postId));

    return Row(
      children: [
        GestureDetector(
          onTap: () => _toggleLike(ref),
          child: isLikedAsyncValue.when(
            data: (isLiked) => Image.asset(
              isLiked
                  ? 'assets/icons/heart_orange.png'
                  : 'assets/icons/heart_grey_empty.png',
              width: 20,
              height: 20,
            ),
            loading: () => Image.asset(
              'assets/icons/heart_grey_empty.png',
              width: 20,
              height: 20,
            ),
            error: (err, stack) => const Icon(Icons.error, size: 20),
          ),
        ),
        const SizedBox(width: 4),
        likeCountAsyncValue.when(
          data: (count) => Text(
            '$count',
            style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
          ),
          loading: () => Text(
            '$likeCount', // Show initial count while loading
            style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
          ),
          error: (err, stack) => Text(
            '!',
            style: textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ),
        const SizedBox(width: 16),
        Image.asset(
          'assets/icons/comment.png',
          width: 20,
          height: 20,
          color: AppColors.n600,
        ),
        const SizedBox(width: 4),
        commentsCountAsync.when(
          data: (count) => Text(
            '$count',
            style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
          ),
          loading: () => Text(
            '...',
            style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
          ),
          error: (err, stack) => const Icon(Icons.error_outline, size: 14),
        ),
      ],
    );
  }
}
