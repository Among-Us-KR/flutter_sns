import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_sns/utils/xss.dart';
import 'package:flutter_sns/write/presentation/providers/upload_provider.dart';

class LoginDetailPage extends ConsumerStatefulWidget {
  const LoginDetailPage({super.key});

  @override
  ConsumerState<LoginDetailPage> createState() => _LoginDetailPageState();
}

class _LoginDetailPageState extends ConsumerState<LoginDetailPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isNicknameValid = false;
  bool _isNicknameContainsBanned = false;
  bool _isNicknameDuplicate = false;
  bool _isNotificationAllowed = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// 닉네임 중복 검사 함수
  Future<bool> _checkNicknameDuplicate(String nickname) async {
    final query = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// 이미지 압축 함수
  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('이미지 압축 오류: $e');
      return null;
    }
  }

  /// 이미지 선택 함수
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (pickedFile == null) return;

      final File originalFile = File(pickedFile.path);
      final compressedFile = await _compressImage(originalFile);

      setState(() {
        _selectedImage = compressedFile ?? originalFile;
      });
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      _showSnackBar('이미지를 불러오는 중 오류가 발생했습니다.');
    }
  }

  /// 프로필 저장 함수
  Future<void> _saveProfile() async {
    final nickname = XssFilter.sanitize(_nicknameController.text.trim());
    
    if (!_isNicknameValid || _isNicknameContainsBanned || _isNicknameDuplicate) {
      _showSnackBar('닉네임을 다시 확인해주세요.');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('로그인 정보가 없습니다.');
      return;
    }

    final uploadNotifier = ref.read(uploadProvider.notifier);

    if (_selectedImage != null) {
      try {
        await uploadNotifier.uploadProfileImage(user.uid, _selectedImage!);
      } catch (e) {
        debugPrint('이미지 업로드 오류: $e');
        _showSnackBar('이미지 업로드에 실패했습니다.');
        return;
      }
    }

    final imageUrl = ref.read(uploadProvider).uploadedImageUrl;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'nickname': nickname,
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        'pushNotifications': _isNotificationAllowed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      debugPrint('프로필 저장 오류: $e');
      _showSnackBar('저장 중 오류가 발생했습니다.');
    }
  }

  /// 스낵바 메시지 출력
  void _showSnackBar(String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final isLoading = uploadState.isLoading;

    // 저장 버튼 활성화 조건
    final canSave = _isNicknameValid &&
        !_isNicknameContainsBanned &&
        !_isNicknameDuplicate &&
        !isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지 선택 영역
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('assets/icons/profile_orange.png')
                              as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 닉네임 입력 필드
                TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  enableIMEPersonalizedLearning: true,
                  autocorrect: true,
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) async {
                    final input = value.trim();
                    final sanitized = XssFilter.sanitize(input);
                    final containsBanned = XssFilter.containsBannedWord(sanitized);

                    // Firestore에서 닉네임 중복 여부 확인
                    final isDuplicate = await _checkNicknameDuplicate(sanitized);

                    setState(() {
                      _isNicknameValid = sanitized.length >= 2 && !containsBanned && !isDuplicate;
                      _isNicknameContainsBanned = containsBanned;
                      _isNicknameDuplicate = isDuplicate;
                    });
                  },
                ),

                // 닉네임 유효성 메시지
                if (_isNicknameContainsBanned)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '입력하실 수 없는 닉네임입니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else if (_isNicknameDuplicate)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '이미 사용 중인 닉네임입니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 24),

                // 알림 설정 스위치
                SwitchListTile(
                  title: const Text('알림 받기 허용'),
                  value: _isNotificationAllowed,
                  onChanged: (bool value) =>
                      setState(() => _isNotificationAllowed = value),
                ),

                const SizedBox(height: 24),

                // 저장 버튼
                ElevatedButton(
                  onPressed: canSave ? _saveProfile : null,
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('저장하고 시작하기'),
                ),
              ],
            ),
          ),

          // 로딩 상태 표시
          if (isLoading)
            const ModalBarrier(dismissible: false, color: Colors.black45),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
