import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_sns/utils/xss.dart'; // xss.dart 경로에 맞게 수정

class LoginDetailPage extends StatefulWidget {
  const LoginDetailPage({super.key});

  @override
  State<LoginDetailPage> createState() => _LoginDetailPageState();
}

class _LoginDetailPageState extends State<LoginDetailPage> {
  final TextEditingController _nicknameController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isNicknameValid = false;
  bool _isNicknameContainsBanned = false;
  bool _isNotificationAllowed = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onNicknameChanged);
  }

  void _onNicknameChanged() {
    final input = _nicknameController.text.trim();
    final sanitized = XssFilter.sanitize(input);
    final containsBanned = XssFilter.containsBannedWord(sanitized);

    setState(() {
      _isNicknameValid = sanitized.length >= 2;
      _isNicknameContainsBanned = containsBanned;
    });
  }

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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      final File originalFile = File(pickedFile.path);

      final tempDir = await getTemporaryDirectory();
      final tempOriginalPath = path.join(
        tempDir.path,
        'original_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final tempOriginalFile = await originalFile.copy(tempOriginalPath);

      final compressedFile = await _compressImage(tempOriginalFile);

      try {
        await tempOriginalFile.delete();
      } catch (e) {
        debugPrint('원본 임시 파일 삭제 실패: $e');
      }

      setState(() {
        _selectedImage = compressedFile ?? originalFile;
      });
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      _showSnackBar('이미지를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _saveProfile() async {
    if (!_isNicknameValid) {
      _showSnackBar('닉네임은 2자 이상 입력해주세요.');
      return;
    }
    if (_isNicknameContainsBanned) {
      _showSnackBar('닉네임에 사용 불가능한 단어가 포함되어 있습니다.');
      return;
    }

    final nickname = XssFilter.sanitize(_nicknameController.text.trim());

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("로그인 정보 없음");

      String? imageUrl;

      if (_selectedImage != null) {
        final ref = _storage.ref().child('user_profiles').child('${user.uid}.jpg');
        await ref.putFile(
          _selectedImage!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await ref.getDownloadURL();

        try {
          await _selectedImage!.delete();
        } catch (e) {
          debugPrint('압축 이미지 삭제 실패: $e');
        }
      }

      await _firestore.collection('users').doc(user.uid).set({
        'nickname': nickname,
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        'pushNotifications': _isNotificationAllowed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    if (!mounted) return; // State의 mounted 체크
        context.go('/');      // 안전하게 라우팅
    } catch (e) {
      debugPrint('프로필 저장 오류: $e');
      _showSnackBar('저장 중 오류가 발생했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('assets/icons/profile_orange.png') as ImageProvider,
                      child: null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_isNicknameContainsBanned)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '입력하실 수 없는 닉네임입니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('알림 받기 허용'),
                  value: _isNotificationAllowed,
                  onChanged: (bool value) {
                    setState(() {
                      _isNotificationAllowed = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_isLoading || !_isNicknameValid || _isNicknameContainsBanned)
                      ? null
                      : _saveProfile,
                  // ignore: sort_child_properties_last
                  child: const Text('저장하고 시작하기'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const ModalBarrier(dismissible: false, color: Colors.black45),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }
}
