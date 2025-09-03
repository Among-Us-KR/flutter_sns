import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/write_page_provider.dart';
import 'package:flutter_sns/write/core/services/message_service.dart';
import 'package:flutter_sns/write/domain/entities/write_mode.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page_viewmodel.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/bottom_button.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/category_selector.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/content_text_input.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/image_carousel.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/mode_card.dart';
import 'package:image_picker/image_picker.dart';

class WritePage extends ConsumerStatefulWidget {
  const WritePage({super.key});

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  final MessageService _messageService = SnackBarMessageService();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 초기 값 바인딩
    final vm = ref.read(writeViewModelProvider);
    _titleCtrl.text = vm.title;
    _contentCtrl.text = vm.content;

    // 변경 사항 -> 뷰모델 반영
    _titleCtrl.addListener(() {
      ref.read(writeViewModelProvider.notifier).updateTitle(_titleCtrl.text);
    });
    _contentCtrl.addListener(() {
      ref
          .read(writeViewModelProvider.notifier)
          .updateContent(_contentCtrl.text);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final state = ref.watch(writeViewModelProvider);
    final vm = ref.read(writeViewModelProvider.notifier);
    final canPost = ref.watch(canPostProvider);

    // 에러/성공 메시지 리스너
    ref.listen<String?>(writeViewModelProvider.select((s) => s.errorMessage), (
      prev,
      next,
    ) {
      if (next != null) {
        _messageService.showError(next);
        vm.clearErrorMessage();
      }
    });
    ref.listen<String?>(
      writeViewModelProvider.select((s) => s.successMessage),
      (prev, next) {
        if (next != null) {
          _messageService.showSuccess(next);
          vm.clearSuccessMessage();
          if (next == '게시글이 성공적으로 작성되었습니다!') {
            if (mounted) Navigator.of(context).pop();
          }
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
              onPressed: canPost ? vm.createPost : null,
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
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 제목 입력 (사진 위)
                TextField(
                  controller: _titleCtrl,
                  maxLength: 30,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: '제목을 입력하세요 (최대 30자)',
                    border: UnderlineInputBorder(),
                    counterText: '',
                    filled: false, // 테마 배경색 방지
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),

                // 이미지 카루셀
                ImageCarouselFreeScroll(
                  images: state.selectedImages, // List<File> 가정
                  onAdd: vm.pickImagesFromGallery,
                  onReplace: (index) =>
                      vm.replaceImage(index, ImageSource.gallery),
                  onRemove: vm.removeImage,
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
                  categories: categories, // viewmodel에 있는 상수
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: vm.selectCategory,
                ),
                const SizedBox(height: 24),

                // 내용
                ContentTextInput(
                  controller: _contentCtrl,
                  maxLength: 1000,
                  onChanged: () {}, // 컨트롤러 리스너에서 처리
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
                        selected: state.selectedMode == WriteMode.empathy,
                        onTap: () => vm.selectMode(WriteMode.empathy),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModeCard(
                        title: '팩폭해줘',
                        subtitle: '솔직하고 직설적인\n말이 필요할 때',
                        selected: state.selectedMode == WriteMode.punch,
                        onTap: () => vm.selectMode(WriteMode.punch),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120), // 하단 버튼 영역 확보
              ],
            ),
          ),
        ),
      ),

      // 하단 버튼
      bottomNavigationBar: BottomButtons(
        isValid: canPost,
        onSubmit: vm.createPost,
        onTempSave: vm.saveDraft,
      ),
    );
  }
}
