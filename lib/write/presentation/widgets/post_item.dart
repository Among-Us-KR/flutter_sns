import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:go_router/go_router.dart';

class PostItem extends StatelessWidget {
  final List<String> imagePaths;
  final String postId;
  final String username;
  final String caption;
  final int likeCount;

  const PostItem({
    super.key,
    required this.postId,
    required this.imagePaths,
    required this.username,
    required this.caption,
    required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _PostImages(imagePaths: imagePaths),
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
          child: _LikeButton(initialLikeCount: likeCount),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: _PostInfo(
            postId: postId,
            username: username,
            caption: caption,
          ),
        ),
      ],
    );
  }
}

// --- PostItem 내부에서만 사용하는 위젯들 (Private Widgets) ---

// 여러 이미지를 좌우로 스와이프하여 보여주는 위젯
class _PostImages extends StatefulWidget {
  final List<String> imagePaths;
  const _PostImages({required this.imagePaths});

  @override
  State<_PostImages> createState() => _PostImagesState();
}

class _PostImagesState extends State<_PostImages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMultipleImages = widget.imagePaths.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          // 이미지가 1개일 때는 스크롤되지 않도록 설정
          physics: hasMultipleImages
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return Image.asset(
              widget.imagePaths[index],
              fit: BoxFit.cover,
              // 이미지를 불러오지 못했을 때를 대비한 에러 위젯
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            );
          },
        ),
        // 이미지가 여러 장일 때만 인디케이터 표시
        if (hasMultipleImages)
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.imagePaths.length}',
                style: AppTypography.caption(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// 좋아요 버튼 위젯
class _LikeButton extends StatefulWidget {
  final int initialLikeCount;
  const _LikeButton({required this.initialLikeCount});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _isLiked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
  }

  void _toggleLike() {
    // TODO: Provider/UseCase와 연동하여 서버에 좋아요 상태 업데이트
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Image.asset(
            _isLiked
                ? 'assets/icons/heart_white.png'
                : 'assets/icons/heart_white_empty.png',
            width: 32,
            height: 32,
          ),
          onPressed: _toggleLike,
        ),
        Text(
          '$_likeCount',
          style: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

// 하단 정보 위젯
class _PostInfo extends StatelessWidget {
  final String postId;
  final String username;
  final String caption;
  const _PostInfo({
    required this.postId,
    required this.username,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    const whiteColor = Colors.white;

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
                const CircleAvatar(radius: 8, backgroundColor: Colors.grey),
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
                // TODO: 실제 데이터 기반으로 시간 표시
                Text(
                  '25분 전',
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
                // TODO: 실제 태그 데이터 표시
                Text('#대박스', style: AppTypography.labelXS(whiteColor)),
                const SizedBox(width: 8),
                Text('#공감해줘', style: AppTypography.labelXS(whiteColor)),
                const Spacer(),

                GestureDetector(
                  onTap: () {
                    // TODO: 댓글 화면으로 이동하는 로직 구현
                  },
                  child: Text(
                    '댓글 10', // TODO: 실제 댓글 수 표시
                    style: AppTypography.labelXS(whiteColor.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
