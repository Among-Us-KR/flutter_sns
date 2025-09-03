import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/write_page_provider.dart';
import 'package:flutter_sns/write/core/services/message_service.dart';
import 'package:flutter_sns/write/domain/entities/category.dart';
import 'package:flutter_sns/write/domain/entities/write_mode.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/bottom_button.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/category_selector.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/content_text_input.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/image_carousel.dart';
import 'package:flutter_sns/write/presentation/screens/write/widgets/mode_card.dart';
import 'package:image_picker/image_picker.dart';

class WritePage extends ConsumerStatefulWidget {
  const WritePage({super.key, this.postId});
  final String? postId;

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  final MessageService _messageService = SnackBarMessageService();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _isLoading = true; // ✅ 로딩 상태 플래그 추가

  @override
  void initState() {
    super.initState();

    // 편집 모드인 경우 데이터 로딩
    if (widget.postId != null) {
      // initState에서는 ref.read를 사용합니다.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // 비동기 작업이 완료될 때까지 기다림
        await ref
            .read(writeViewModelProvider.notifier)
            .loadPostForEdit(widget.postId!);
        // 데이터 로딩이 완료되면 로딩 상태를 false로 변경
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      // 새 글 작성 모드일 경우 바로 로딩 완료
      _isLoading = false;
    }

    // 뷰모델 상태 변화를 구독하고 UI 컨트롤러를 업데이트합니다.
    ref.listenManual(writeViewModelProvider, (previous, next) {
      // 뷰모델의 제목이 컨트롤러의 텍스트와 다를 때만 업데이트
      if (next.title != _titleCtrl.text) {
        _titleCtrl.text = next.title;
      }
      // 뷰모델의 내용이 컨트롤러의 텍스트와 다를 때만 업데이트
      if (next.content != _contentCtrl.text) {
        _contentCtrl.text = next.content;
      }
    });

    // 텍스트 컨트롤러 변경 사항을 뷰모델에 즉시 반영
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
          // 게시글 작성 또는 수정 완료 시 화면 이동
          if (mounted) {
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
        // 편집 모드에 따라 앱바 제목 변경
        title: Text(
          state.isEditMode ? '게시글 수정' : '새로운 게시글',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              // 편집 모드에 따라 호출할 메서드 변경
              onPressed: canPost
                  ? () {
                      if (state.isEditMode) {
                        vm.updatePost();
                      } else {
                        vm.createPost();
                      }
                    }
                  : null,
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
                // 편집 모드에 따라 버튼 텍스트 변경
                state.isEditMode ? '수정' : '완료',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      // ✅ 로딩 중일 때 로딩 인디케이터 표시
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ 제목 입력 (사진 위)
                      Text(
                        '제목',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _titleCtrl,
                          maxLength: 30,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: '제목을 입력하세요 (최대 30자)',
                            border: InputBorder.none, // 기존 밑줄 제거
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 이미지 카루셀
                      ImageCarouselFreeScroll(
                        // 뷰모델 상태에 따라 보여줄 이미지 리스트를 결정
                        images: state.isEditMode
                            ? state.uploadedImageUrls
                            : state.selectedImages,
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
                        categories: Category.values
                            .skip(1)
                            .map((c) => c.displayName)
                            .toList(),
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: vm.selectCategory,
                      ),
                      const SizedBox(height: 24),

                      // 내용
                      ContentTextInput(
                        controller: _contentCtrl,
                        maxLength: 1000,
                        onChanged: () {},
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
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),

      bottomNavigationBar: BottomButtons(
        isValid: canPost,
        onSubmit: () {
          if (state.isEditMode) {
            vm.updatePost();
          } else {
            vm.createPost();
          }
        },
        onTempSave: vm.saveDraft,
        isEditMode: state.isEditMode,
      ),
    );
  }
}
