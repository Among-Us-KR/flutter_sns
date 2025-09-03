import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';

/// 화면 하단에 고정되는 댓글 입력창 위젯
class CommentInputField extends StatefulWidget {
  const CommentInputField({super.key});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      // 위젯이 마운트된 상태인지 확인
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
        decoration: const BoxDecoration(
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
