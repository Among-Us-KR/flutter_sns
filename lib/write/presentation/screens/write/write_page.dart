import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sns/write/core/services/message_service.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/bottom_button.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/category_selector.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/content_text_input.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/image_carousel.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/mode_card.dart';
import 'package:image_picker/image_picker.dart';

// 파일 최상단에 enum 배치
enum WriteMode { empathy, punch }

// 상수 정의
class WritePageConstants {
  static const int maxImages = 5;
  static const int maxTextLength = 1000;
  static const double maxImageSizeMB = 5.0;
  static const Duration animationDuration = Duration(milliseconds: 250);
}

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final MessageService _messageService = SnackBarMessageService(); // 추가
  final _contentCtrl = TextEditingController();
  final _picker = ImagePicker();

  // 이미지(최대 5장)
  final List<XFile> _images = [];

  // TODO: 서버 연동 시 활성화
  // bool _isUploading = false;
  // String? _errorMessage;

  final _categories = const [
    '멍청스',
    '고민스',
    '대박스',
    '행복스',
    '슬펐스',
    '빡쳤스',
    '놀랐스',
    '솔직스',
  ];
  String? _selectedCategory;

  WriteMode? _mode;

  // 강화된 유효성 검사
  bool get _isValid {
    final text = _contentCtrl.text.trim();
    return (_selectedCategory != null) &&
        text.isNotEmpty &&
        text.length <= WritePageConstants.maxTextLength &&
        _mode != null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  // 이미지 크기 검증
  Future<bool> _validateImageSize(XFile image) async {
    try {
      final file = File(image.path);
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      final maxSizeBytes = WritePageConstants.maxImageSizeMB * 1024 * 1024;

      if (fileSize > maxSizeBytes) {
        _messageService.showError(
          '이미지 크기는 ${WritePageConstants.maxImageSizeMB}MB 이하여야 합니다',
        );
        return false;
      }
      return true;
    } catch (e) {
      _messageService.showError('이미지 파일을 확인할 수 없습니다');
      return false;
    }
  }

  Future<void> _addImages() async {
    final remain = WritePageConstants.maxImages - _images.length;
    if (remain <= 0) {
      _messageService.showError(
        '최대 ${WritePageConstants.maxImages}장까지만 추가할 수 있습니다',
      );
      return;
    }

    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;

      // 이미지 크기 검증
      final validImages = <XFile>[];
      for (final image in picked.take(remain)) {
        if (await _validateImageSize(image)) {
          validImages.add(image);
        }
      }

      if (validImages.isEmpty) return;

      setState(() {
        _images.addAll(validImages);
      });
    } catch (e) {
      _messageService.showError('이미지를 불러오는 중 오류가 발생했습니다');
    }
  }

  Future<void> _replaceAt(int index) async {
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery);
      if (x == null) return;

      if (await _validateImageSize(x)) {
        setState(() => _images[index] = x);
        _messageService.showSuccess('이미지가 교체되었습니다');
      }
    } catch (e) {
      _messageService.showError('이미지 교체 중 오류가 발생했습니다');
    }
  }

  void _removeAt(int index) {
    if (index < 0 || index >= _images.length) return;

    setState(() {
      _images.removeAt(index);
    });
  }

  void _onSubmit() {
    if (!_isValid) {
      _messageService.showError('모든 필수 항목을 입력해주세요');
      return;
    }

    // TODO: Firebase 업로드 구현
    // setState(() => _isUploading = true);
    // try {
    //   await _uploadToFirebase();
    //   _showSuccess('게시글이 업로드되었습니다!');
    //   Navigator.of(context).pop();
    // } catch (e) {
    //   _showError('업로드 실패: ${e.toString()}');
    // } finally {
    //   if (mounted) setState(() => _isUploading = false);
    // }

    // 임시: 단순 화면 닫기
    _messageService.showSuccess('게시글이 작성되었습니다! (임시)');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '새로운 게시글',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isValid ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.secondary,
                foregroundColor: cs.onSecondary,
                minimumSize: const Size(52, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                '완료',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // 빈 공간 탭도 인식
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 카루셀
                ImageCarouselFreeScroll(
                  images: _images,
                  onAdd: _addImages,
                  onReplace: _replaceAt,
                  onRemove: _removeAt,
                ),
                const SizedBox(height: 10),
                Text(
                  '*사람 또는 신체부위가 포함된 사진은 업로드되지 않습니다',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // 카테고리
                CategorySelector(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) =>
                      setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 24),

                // 내용
                ContentTextInput(
                  controller: _contentCtrl,
                  maxLength: WritePageConstants.maxTextLength,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 24),

                // 모드 선택
                Text(
                  '모드 선택',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ModeCard(
                        title: '공감해줘',
                        subtitle: '따뜻하고 다정한\n말이 필요할 때',
                        selected: _mode == WriteMode.empathy,
                        onTap: () => setState(() => _mode = WriteMode.empathy),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModeCard(
                        title: '팩폭해줘',
                        subtitle: '솔직하고 직설적인\n말이 필요할 때',
                        selected: _mode == WriteMode.punch,
                        onTap: () => setState(() => _mode = WriteMode.punch),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120), // 하단 버튼 공간 확보
              ],
            ),
          ),
        ),
      ),

      // 하단 버튼
      bottomNavigationBar: BottomButtons(
        isValid: _isValid,
        onSubmit: _onSubmit,
        onTempSave: null, // TODO: 임시저장 기능 구현 시 활성화
      ),
    );
  }
}
