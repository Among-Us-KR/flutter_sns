import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAgree = false;
  bool _isLoading = false;

  /// ✅ 구글 로그인
  Future<void> _signInWithGoogle() async {
    if (!_isAgree) {
      _showSnackBar('계속하려면 동의가 필요합니다.');
      return;
    }

    final confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        if (!mounted) return;
        _showSnackBar('로그인이 취소되었습니다.');
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final uid = user.uid;
        final docRef = _firestore.collection('users').doc(uid);
        final doc = await docRef.get();

        if (doc.exists) {
          // ✅ 기존 사용자인 경우
          if (!mounted) return;
          context.goNamed('home'); // 바로 홈 화면으로 이동
        } else {
          // ✅ 신규 사용자인 경우
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'nickname': null,
            'profileImageUrl': null,
            'privacyConsent': {
              'agreedAt': DateTime.now().toIso8601String(),
              'version': '1.0',
              'ipAddress': '',
            },
            'stats': {'postsCount': 0, 'commentsCount': 0, 'likesReceived': 0},
            'pushNotifications': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'reportCount': 0,
          });
          if (!mounted) return;
          context.go('/login-detail'); // 닉네임 설정 페이지로 이동
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      if (e.code == 'sign_in_canceled') {
        _showSnackBar('로그인이 취소되었습니다.');
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      } else {
        _showSnackBar('플랫폼 오류 발생: ${e.message}');
      }
      debugPrint('PlatformException: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('알 수 없는 오류가 발생했습니다.');
      debugPrint('Sign-in error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ✅ 로그인 전 확인 다이얼로그
  Future<bool> _showConfirmDialog() async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('구글 로그인'),
            content: const Text('구글 계정으로 로그인하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('계속'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// ✅ 스낵바 메시지 출력
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/logo_horizontal.png', fit: BoxFit.cover),
            const SizedBox(height: 16),
            const Text('지친 현생을 위한 익명 휴게소', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            CheckboxListTile(
              title: const Text(
                '서비스 이용 약관 및 개인정보 처리방침에 동의합니다.',
                style: TextStyle(fontSize: 12),
              ),
              value: _isAgree,
              onChanged: (val) => setState(() => _isAgree = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('구글로 로그인'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
