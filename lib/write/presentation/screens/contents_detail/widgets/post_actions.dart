import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

class PostActions extends StatefulWidget {
  final int likeCount;
  final int commentCount;

  const PostActions({
    super.key,
    required this.likeCount,
    required this.commentCount,
  });

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
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
