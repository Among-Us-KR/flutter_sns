import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/providers/post_interaction_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// 하단 정보 위젯
class PostInfo extends ConsumerWidget {
  final String postId;
  final String username;
  final String caption;
  final DateTime createdAt;
  final int commentCount;
  final String? profileImageUrl;
  final String category;
  final String mode;

  const PostInfo({
    super.key,
    required this.postId,
    required this.username,
    required this.caption,
    required this.createdAt,
    required this.commentCount,
    this.profileImageUrl,
    required this.category,
    required this.mode,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('yy.MM.dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const whiteColor = Colors.white;
    final commentsCountAsync = ref.watch(commentsCountProvider(postId));

    // 실제 태그 데이터를 기반으로 태그 목록을 생성합니다.
    final tags = [
      category,
      mode == 'punch' ? '팩폭해줘' : '공감해줘',
    ].where((tag) => tag.isNotEmpty).toList();

    // GestureDetector로 감싸서 탭 이벤트를 감지하고, 탭하면 게시물 상세 페이지로 이동
    return GestureDetector(
      onTap: () => context.go('/post/$postId'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.grey,
                  // Use a backgroundImage if the URL is not null
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  // Display a default icon if there's no image
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  username,
                  style: AppTypography.style(
                    AppTypography.s12,
                    weight: AppTypography.bold,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeAgo(createdAt),
                  style: AppTypography.caption(whiteColor.withOpacity(0.8)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(whiteColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 동적으로 태그 위젯들을 생성합니다.
                ...tags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '#$tag',
                      style: AppTypography.labelXS(whiteColor),
                    ),
                  ),
                ),
                const Spacer(),
                commentsCountAsync.when(
                  data: (count) => Text(
                    '댓글 $count',
                    style: AppTypography.labelXS(whiteColor.withOpacity(0.8)),
                  ),
                  loading: () => Text(
                    '댓글 $commentCount', // 로딩 중에는 기존 stats 값 표시
                    style: AppTypography.labelXS(whiteColor.withOpacity(0.8)),
                  ),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
