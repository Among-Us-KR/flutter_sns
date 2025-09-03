import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/contents_detail_page.dart';

/// 화면 하단에 고정되는 댓글 입력창 위젯
class CommentInputField extends ConsumerStatefulWidget {
  final String postId;
  const CommentInputField({super.key, required this.postId});

  @override
  ConsumerState<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends ConsumerState<CommentInputField> {
  final _textController = TextEditingController();
  bool _canSend = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (!mounted) return;
      setState(() {
        _canSend = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_canSend || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final content = _textController.text;
      await ref
          .read(commentServiceProvider)
          .addComment(postId: widget.postId, content: content);
      _textController.clear();
    } catch (e, s) {
      // 디버깅을 위해 콘솔에 에러와 스택 트레이스 출력
      print('댓글 작성 오류: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('댓글 작성에 실패했습니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.n300, width: 1.0)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: AppColors.n100),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '따뜻한 공감 댓글 작성하기',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.n400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.n400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.brand),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Image.asset(
                            'assets/icons/send.png',
                            width: 24,
                            height: 24,
                            color: _canSend ? AppColors.brand : AppColors.n600,
                          ),
                          onPressed: _onSend,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
