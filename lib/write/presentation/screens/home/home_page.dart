import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈 화면')), // 상단 앱바
      body: const Center(
        child: Text('여기는 홈입니다!'), // 본문 내용
      ),
    );
  }
}
