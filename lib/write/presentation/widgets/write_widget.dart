import 'package:flutter/material.dart';

// 재사용 가능한 위젯 컴포넌트 예시

class WriteWidget extends StatelessWidget {
  final String text;

  const WriteWidget({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
