import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sns/theme/theme.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameDuplicate = false; // TODO: 중복 체크 결과 반영 필요
  File? _profileImage; // 프로필 이미지 상태

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isFormValid =
        _nicknameController.text.isNotEmpty &&
        _profileImage != null &&
        !_isNicknameDuplicate;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text('프로필', style: theme.textTheme.headlineLarge),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 170,
              color: cs.onSecondaryContainer,
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 오렌지 보더 원형 아바타
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 4),
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 104, // radius 52 * 2
                        height: 104,
                        child: _profileImage != null
                            ? Image.file(_profileImage!, fit: BoxFit.cover)
                            : Image.network(
                                'https://picsum.photos/200',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  // 카메라 배지 버튼
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Material(
                      color: cs.primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _pickImage,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 닉네임 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '닉네임',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.n600,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nicknameController,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.n700,
                    ),
                    cursorColor: AppColors.n700,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 8),
                      hintText: '닉네임을 입력하세요',
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.n600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.n700, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.n900, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            if (_isNicknameDuplicate)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '이미 사용 중인 닉네임입니다.',
                  style: TextStyle(color: cs.error, fontSize: 14),
                ),
              ),

            const Spacer(),

            // 저장 버튼 (닉네임 + 이미지 둘 다 있을 때만 활성)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                          // TODO: 저장 로직
                          Navigator.of(context).pop();
                        }
                      : null, // 비활성 상태는 자동으로 disabled 처리
                  style: isFormValid
                      ? null // 기본 ElevatedButtonTheme 적용
                      : ElevatedButton.styleFrom(
                          backgroundColor: cs.onSurface.withValues(alpha: 0.12),
                          foregroundColor: cs.onSurface, // 글자색
                        ),
                  child: const Text('저장하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
