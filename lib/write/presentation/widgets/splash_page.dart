import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final String _fullText = '지친 현생을 위한 익명 휴게소';
  String _visibleText = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  bool _animationStarted = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // 애니메이션 끝나면 상태 확인 후 페이지 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });

    // 타자 효과 시작
    _startTyping();
  }

  void _startTyping() {
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

  // 로그인 및 프로필 상태 체크 후 적절한 화면으로 이동
  Future<void> _checkAuthAndNavigate() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (context.mounted) context.go('/login');
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

  if (!doc.exists) {
    if (!mounted) return; // mounted 체크 먼저
    context.go('/login');  // 안전하게 context 사용
    return;
  }

    final data = doc.data();
    final nickname = data?['nickname'] as String?;

   if (nickname == null || nickname.isEmpty) {
      if (!mounted) return;   // 위젯이 화면에 있는지 확인
      context.go('/login-detail');  // 안전하게 라우팅
      return;
    }


    if (!mounted) return;  // 위젯이 아직 화면에 있는지 확인
    context.go('/');       // 안전하게 라우팅 실행
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
