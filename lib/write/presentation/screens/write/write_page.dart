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

class WritePageConstants {
  static const int maxTextLength = 1000;
  static const Duration animationDuration = Duration(milliseconds: 250);
}

class WritePage extends ConsumerStatefulWidget {
  const WritePage({super.key});

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  final MessageService _messageService = SnackBarMessageService();
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 뷰모델의 콘텐츠를 컨트롤러에 바인딩
    final viewModel = ref.read(writeViewModelProvider);
    _contentCtrl.text = viewModel.content;
    _contentCtrl.addListener(() {
      // 컨트롤러 변경 시 뷰모델에 전달
      ref
          .read(writeViewModelProvider.notifier)
          .updateContent(_contentCtrl.text);
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  // 빌드 메서드에서 Provider의 상태를 'ref.watch'로 관찰
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final viewModel = ref.watch(writeViewModelProvider);
    final viewModelNotifier = ref.read(writeViewModelProvider.notifier);
    final canPost = ref.watch(canPostProvider);

    // 에러/성공 메시지 알림
    ref.listen<String?>(writeViewModelProvider.select((s) => s.errorMessage), (
      prev,
      next,
    ) {
      if (next != null) {
        _messageService.showError(next);
        viewModelNotifier.clearErrorMessage();
      }
    });
    ref.listen<String?>(
      writeViewModelProvider.select((s) => s.successMessage),
      (prev, next) {
        if (next != null) {
          _messageService.showSuccess(next);
          viewModelNotifier.clearSuccessMessage();
          if (next == '게시글이 성공적으로 작성되었습니다!') {
            Navigator.of(context).pop();
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
              // 뷰모델의 상태에 따라 버튼 활성화/비활성화
              onPressed: canPost ? () => viewModelNotifier.createPost() : null,
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
                // 뷰모델의 이미지 리스트를 바인딩
                ImageCarouselFreeScroll(
                  images: viewModel.selectedImages,
                  // 뷰모델의 메서드를 이벤트 콜백으로 전달
                  onAdd: () => viewModelNotifier.pickImagesFromGallery(),
                  onReplace: (index) => viewModelNotifier.replaceImage(
                    index,
                    ImageSource.gallery,
                  ),
                  onRemove: (index) => viewModelNotifier.removeImage(index),
                ),
                const SizedBox(height: 10),
                Text(
                  '*사람 또는 신체부위가 포함된 사진은 업로드되지 않습니다',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // 뷰모델의 카테고리 상태와 연결
                CategorySelector(
                  categories: categories,
                  selectedCategory: viewModel.selectedCategory,
                  onCategorySelected: (category) =>
                      viewModelNotifier.selectCategory(category),
                ),
                const SizedBox(height: 24),

                // 뷰모델의 컨트롤러와 연결
                ContentTextInput(
                  controller: _contentCtrl,
                  maxLength: 1000,
                  onChanged: () {}, // onChanged는 TextEditingController가 처리
                ),
                const SizedBox(height: 24),

                // 모드 선택은 아직 뷰모델에 없으므로, 필요에 따라 추가
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
                        selected:
                            viewModel.selectedMode ==
                            WriteMode.empathy, // 뷰모델과 바인딩
                        onTap: () => viewModelNotifier.selectMode(
                          WriteMode.empathy,
                        ), // 뷰모델의 메서드 호출
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModeCard(
                        title: '팩폭해줘',
                        subtitle: '솔직하고 직설적인\n말이 필요할 때',
                        selected:
                            viewModel.selectedMode ==
                            WriteMode.punch, // 뷰모델과 바인딩
                        onTap: () => viewModelNotifier.selectMode(
                          WriteMode.punch,
                        ), // 뷰모델의 메서드 호출
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),

      // 하단 버튼
      bottomNavigationBar: BottomButtons(
        isValid: canPost,
        onSubmit: () => viewModelNotifier.createPost(),
        onTempSave: () => viewModelNotifier.saveDraft(),
      ),
    );
  }
}
