import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final String _fullText = '지친 현생을 위한 익명 휴게소';
  String _visibleText = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 애니메이션 지속 시간
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 애니메이션 끝나면 다음 페이지 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go('/');
      }
    });

    // 타자 효과 시작
    _startTyping();
  }

  void _startTyping() { // 타자 효과 
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) { 
      if (_charIndex < _fullText.length) {
        setState(() {
          _visibleText += _fullText[_charIndex];
          _charIndex++;
        });
      } else {
        _typingTimer?.cancel();
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    if (!_animationStarted) {
      _animationStarted = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo/logo_vertical.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _visibleText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
