import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러 및 애니메이션 변수 선언
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (2초)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 크기 애니메이션: 1배 → 2배로 커짐
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 불투명도 애니메이션: 1.0 → 0.0 (점점 투명해짐)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 애니메이션 시작
    _controller.forward();

    // 애니메이션이 끝나면 HomePage로 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    // 애니메이션 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 스플래시 배경색
      body: Center(
        child: AnimatedBuilder(
          animation: _controller, // 애니메이션 값 변경 감지
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value, // 이미지 크기 조절
              child: Opacity(
                opacity: _opacityAnimation.value, // 이미지 투명도 조절
                child: Image.asset(
                  'assets/logo/logo_vertical.png', // 로고 이미지 경로
                  width: 150,
                  height: 150,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
