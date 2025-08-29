import 'package:flutter/material.dart';

// 화면 단위 UI 위젯

class WriteScreen extends StatelessWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write Screen')),
      body: Center(child: Text('This is the Write screen')),
    );
  }
}
