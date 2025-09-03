// presentation/viewmodels/write_page_viewmodel.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/write_mode.dart'; // import 추가
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// categories 리스트를 WriteState 클래스 바깥으로 이동
const categories = <String>[
  '멍청스',
  '고민스',
  '대박스',
  '행복스',
  '슬펐스',
  '빡쳤스',
  '놀랐스',
  '솔직스',
];

// 상태 클래스는 그대로 사용
class WriteState {
  final String title;
  final String content;
  final String selectedCategory;
  final WriteMode? selectedMode; // 이 부분 추가
  final List<File> selectedImages;
  final List<String> uploadedImageUrls;

  final bool isLoading;
  final bool isImageUploading;
  final bool isPosting;

  final String? errorMessage;
  final String? successMessage;

  final int titleLength;
  final int contentLength;

  const WriteState({
    this.title = '',
    this.content = '',
    this.selectedCategory = '',
    this.selectedMode, // 이 부분 추가
    this.selectedImages = const [],
    this.uploadedImageUrls = const [],
    this.isLoading = false,
    this.isImageUploading = false,
    this.isPosting = false,
    this.errorMessage,
    this.successMessage,
    this.titleLength = 0,
    this.contentLength = 0,
  });

  WriteState copyWith({
    String? title,
    String? content,
    String? selectedCategory,
    WriteMode? selectedMode, // 이 부분 추가
    List<File>? selectedImages,
    List<String>? uploadedImageUrls,
    bool? isLoading,
    bool? isImageUploading,
    bool? isPosting,
    String? errorMessage,
    String? successMessage,
    int? titleLength,
    int? contentLength,
  }) {
    return WriteState(
      title: title ?? this.title,
      content: content ?? this.content,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMode: selectedMode ?? this.selectedMode, // 이 부분 추가
      selectedImages: selectedImages ?? this.selectedImages,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
      isLoading: isLoading ?? this.isLoading,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      isPosting: isPosting ?? this.isPosting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      titleLength: titleLength ?? this.titleLength,
      contentLength: contentLength ?? this.contentLength,
    );
  }

  // 뷰모델 상태를 기반으로 유효성 검사를 수행하는 게터
  bool get isTitleValid => title.trim().isNotEmpty && title.length <= 30;
  bool get isContentValid =>
      content.trim().isNotEmpty && content.length <= 1000;
  bool get isCategoryValid => selectedCategory.isNotEmpty;
  bool get isModeValid => selectedMode != null; // 이 부분 추가
  bool get isFormValid =>
      isTitleValid &&
      isContentValid &&
      isCategoryValid &&
      isModeValid; // 이 부분 수정
}

// 도메인 의존성을 콜백으로 주입
typedef CreatePost = Future<String> Function(Posts post);
typedef UploadImages = Future<List<String>> Function(List<File> files);

class WriteViewModel extends StateNotifier<WriteState> {
  final CreatePost _createPost;
  final UploadImages _uploadImages;
  final ImagePicker _imagePicker;

  WriteViewModel({
    required CreatePost createPost,
    required UploadImages uploadImages,
    required ImagePicker imagePicker,
  }) : _createPost = createPost,
       _uploadImages = uploadImages,
       _imagePicker = imagePicker,
       super(const WriteState());

  // 텍스트 업데이트 로직
  void updateTitle(String v) => state = state.copyWith(
    title: v,
    titleLength: v.length,
    errorMessage: null,
  );

  void updateContent(String v) => state = state.copyWith(
    content: v,
    contentLength: v.length,
    errorMessage: null,
  );

  // 카테고리 선택 로직
  void selectCategory(String c) =>
      state = state.copyWith(selectedCategory: c, errorMessage: null);

  // 모드 선택 로직
  void selectMode(WriteMode m) =>
      state = state.copyWith(selectedMode: m, errorMessage: null); // 이 부분 추가

  // 이미지 갤러리에서 선택 (UI 로직)
  Future<void> pickImagesFromGallery() async {
    try {
      final xs = await _imagePicker.pickMultiImage();
      if (xs.isEmpty) return;
      final files = xs.map((x) => File(x.path)).toList();
      final total = [...state.selectedImages, ...files];
      if (total.length > 5) {
        state = state.copyWith(errorMessage: '이미지는 최대 5개까지 선택할 수 있습니다.');
        return;
      }
      state = state.copyWith(selectedImages: total, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: '이미지 선택 오류: $e');
    }
  }

  // 이미지 교체 로직
  Future<void> replaceImage(int index, ImageSource source) async {
    try {
      final x = await _imagePicker.pickImage(source: source);
      if (x == null) return;
      final file = File(x.path);
      final list = List<File>.from(state.selectedImages);
      if (index >= 0 && index < list.length) {
        list[index] = file;
        state = state.copyWith(selectedImages: list, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: '이미지 교체 오류: $e');
    }
  }

  // 이미지 삭제 로직
  void removeImage(int index) {
    final list = List<File>.from(state.selectedImages);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    state = state.copyWith(selectedImages: list, errorMessage: null);
  }

  // 게시글 작성 (도메인 로직 호출 및 에러 처리)
  Future<void> createPost() async {
    // 뷰모델 수준의 폼 유효성 검사
    if (!state.isFormValid) {
      state = state.copyWith(
        errorMessage: '제목, 내용, 카테고리, 모드를 모두 입력해주세요.',
      ); // 이 부분 수정
      return;
    }

    // 로그인된 사용자 정보 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }

    state = state.copyWith(
      isPosting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      // 1) 이미지 업로드 (유즈케이스의 유효성 검사 포함)
      List<String> urls = [];
      if (state.selectedImages.isNotEmpty) {
        state = state.copyWith(isImageUploading: true);
        urls = await _uploadImages(state.selectedImages);
        state = state.copyWith(
          isImageUploading: false,
          uploadedImageUrls: urls,
        );
      }

      // 2) 도메인 엔티티 생성
      final now = DateTime.now();
      final post = Posts(
        id: '',
        authorId: user.uid,
        author: Author(
          nickname: user.displayName ?? '익명',
          profileImageUrl: user.photoURL ?? '',
        ),
        category: state.selectedCategory,
        mode: state.selectedMode!.name,
        title: state.title.trim(),
        content: state.content.trim(),
        images: urls,
        stats: PostStats(likesCount: 0, commentsCount: 0),
        createdAt: now,
        updatedAt: now,
        reportCount: 0,
      );

      // 3) 게시글 생성 (유즈케이스의 유효성 검사 포함)
      await _createPost(post);

      state = state.copyWith(
        isPosting: false,
        successMessage: '게시글이 성공적으로 작성되었습니다!',
      );
      _resetForm();
    } catch (e) {
      // 유즈케이스에서 발생한 예외를 여기서 받아서 처리
      state = state.copyWith(
        isPosting: false,
        isImageUploading: false,
        errorMessage: e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : '알 수 없는 오류가 발생했습니다.',
      );
    }
  }

  void _resetForm() => state = const WriteState();
  void saveDraft() => state = state.copyWith(successMessage: '임시저장되었습니다.');
  void clearErrorMessage() => state = state.copyWith(errorMessage: null);
  void clearSuccessMessage() => state = state.copyWith(successMessage: null);
}
