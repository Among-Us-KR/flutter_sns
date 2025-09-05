import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_edit_view_model.dart';
import 'package:image_picker/image_picker.dart';

// StatefulWidget을 ConsumerStatefulWidget으로 변경
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

// State도 ConsumerState로 변경
class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시, 뷰모델의 현재 닉네임을 컨트롤러에 바인딩
    final state = ref.read(profileEditViewModelProvider);
    _nicknameController.text = state.nickname;

    // 컨트롤러의 리스너를 추가하여 텍스트 변경을 뷰모델에 알림
    _nicknameController.addListener(() {
      ref
          .read(profileEditViewModelProvider.notifier)
          .updateNickname(_nicknameController.text);
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        // 선택된 이미지를 뷰모델에 전달합니다.
        ref
            .read(profileEditViewModelProvider.notifier)
            .setProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      // 에러 발생 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택에 실패했습니다: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 뷰모델의 상태를 watch하여 UI를 업데이트
    final state = ref.watch(profileEditViewModelProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_nicknameController.text != state.nickname) {
      _nicknameController.text = state.nickname;
    }
    // 폼 유효성 검사를 뷰모델 상태에 따라 결정
    final isFormValid =
        _nicknameController.text.isNotEmpty &&
        !state.isNicknameDuplicate &&
        !state.isSaving;

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
                  // 프로필 이미지 표시 (뷰모델 상태에 따라 분기)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 4),
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 104,
                        height: 104,
                        child: state.profileImageFile != null
                            ? Image.file(
                                state.profileImageFile!,
                                fit: BoxFit.cover,
                              )
                            : (state.profileImageUrl != null &&
                                      state.profileImageUrl!.isNotEmpty
                                  ? Image.network(
                                      state.profileImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      // 기존 Image.asset을 Container로 변경
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cs.surfaceContainerHigh,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    )),
                      ),
                    ),
                  ),
                  // 카메라 버튼
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
                  const SizedBox(height: 10),
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
                    // onChanged 로직 제거: 리스너가 대신 처리
                  ),
                ],
              ),
            ),
            // 중복 메시지 표시 (뷰모델 상태에 따라)
            if (state.isNicknameDuplicate)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '이미 사용 중인 닉네임입니다.',
                  style: TextStyle(color: cs.error, fontSize: 14),
                ),
              ),
            const Spacer(),
            // 저장 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () async {
                          final success = await ref
                              .read(profileEditViewModelProvider.notifier)
                              .saveProfile();
                          if (success && mounted) {
                            // This line is crucial for refreshing the previous page.
                            print('DEBUG: 프로필 업데이트 성공! 이제 프로필 탭을 새로고침합니다.');
                            ref.invalidate(userProfileProvider);
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  style: isFormValid
                      ? null
                      : ElevatedButton.styleFrom(
                          backgroundColor: cs.onSurface.withValues(alpha: 0.12),
                          foregroundColor: cs.onSurface.withValues(alpha: 0.38),
                        ),
                  child: Text(state.isSaving ? '저장 중...' : '저장하기'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
