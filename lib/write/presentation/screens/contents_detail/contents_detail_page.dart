import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';

class ContentsDetailPage extends StatelessWidget {
  const ContentsDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 스크롤 시 앱바 색상이 변하는 것을 방지
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text('Post #$postId'), // postId를 사용하여 제목 표시
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // 편집 삭제 로직 구현 예정
            },
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: ListView(
          children: [
            _buildPostContent(context),
            const Divider(height: 1, thickness: 1),
            _buildCommentSection(context),
          ],
        ),
      ),
      bottomNavigationBar: const _CommentInputField(),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Text(
            '타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀타이틀..',
            style: AppTypography.h3(AppColors.n900),
          ),
          const SizedBox(height: 16),

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

          Text(
            '내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용',
            style: AppTypography.body(AppColors.n800),
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            // 네트워크 불안정성 문제를 피하기 위해 로컬 애셋 이미지로 변경
            child: Image.asset(
              'assets/images/cat_image.jpeg',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 16),

          const _PostActions(likeCount: 20, commentCount: 2),
        ],
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // TODO: 실제 댓글 데이터로 교체예정
    final List<_CommentTile> commentTiles = [
      const _CommentTile(
        username: '쌩나는햄스터',
        timestamp: '2025-08-28 15:30',
        comment: '댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당댓글내용입니당',
      ),
      const _CommentTile(
        username: '웃긴거북이',
        timestamp: '2025-08-28 15:30',
        comment: '댓글내용입니당댓글내용입니당',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${commentTiles.length}',
            style: textTheme.titleMedium?.copyWith(color: AppColors.n900),
          ),
          const SizedBox(height: 16),
          ...commentTiles.map(
            (tile) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: tile,
            ),
          ),
        ],
      ),
    );
  }
}

/// 게시물 하단 액션 버튼 (좋아요, 댓글) 위젯
class _PostActions extends StatefulWidget {
  final int likeCount;
  final int commentCount;

  const _PostActions({required this.likeCount, required this.commentCount});

  @override
  State<_PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<_PostActions> {
  late int _likeCount;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleLike,
          child: Image.asset(
            _isLiked
                ? 'assets/icons/heart_orange.png'
                : 'assets/icons/heart_grey_empty.png',
            width: 20,
            height: 20,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$_likeCount',
          style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
        ),
        const SizedBox(width: 16),
        Image.asset(
          'assets/icons/comment.png',
          width: 20,
          height: 20,
          color: AppColors.n600,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.commentCount}',
          style: textTheme.bodySmall?.copyWith(color: AppColors.n600),
        ),
      ],
    );
  }
}

/// 개별 댓글 타일 위젯
class _CommentTile extends StatelessWidget {
  final String username;
  final String timestamp;
  final String comment;

  const _CommentTile({
    required this.username,
    required this.timestamp,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(timestamp, style: AppTypography.caption(AppColors.n600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: textTheme.bodySmall?.copyWith(color: AppColors.n700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 하단 댓글 입력 필드 위젯
class _CommentInputField extends StatefulWidget {
  const _CommentInputField();

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (!mounted) return;
      setState(() {
        _canSend = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSend() {
    // TODO: 댓글 전송 로직 구현
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.n300, width: 1.0)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: AppColors.n100),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.n400),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          fillColor: Colors.transparent,
                          filled: true,
                          hintText: '따뜻한 공감 댓글 작성하기',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _canSend ? _onSend : null,
                      child: Image.asset(
                        'assets/icons/send.png',
                        width: 24,
                        height: 24,
                        color: _canSend ? AppColors.brand : AppColors.n600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
