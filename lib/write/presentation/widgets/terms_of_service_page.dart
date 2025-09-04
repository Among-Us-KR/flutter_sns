import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 자바스크립트 허용
      ..setBackgroundColor(const Color(0xFFFFFFFF))    // 흰색 배경
      ..loadRequest(
        Uri.parse("https://phase-attraction-454.notion.site/2025-09-02-264ed237170f817889c4c1f2304fe465?source=copy_link"), // ✅ 외부 개인정보 처리방침 URL
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개인정보 처리방침")),
      body: WebViewWidget(controller: _controller),
    );
  }
}