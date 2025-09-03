import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/write_mode.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/delete_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/get_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/update_post_usecase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 상태 클래스
class WriteState {
  final String title;
  final String content;
  final String selectedCategory;
  final WriteMode? selectedMode;
  final List<File> selectedImages;
  final List<String> uploadedImageUrls;

  final bool isLoading;
  final bool isImageUploading;
  final bool isPosting;

  final String? errorMessage;
  final String? successMessage;

  final int titleLength;
  final int contentLength;

  final String? postId;
  final bool isEditMode;

  const WriteState({
    this.title = '',
    this.content = '',
    this.selectedCategory = '',
    this.selectedMode,
    this.selectedImages = const [],
    this.uploadedImageUrls = const [],
    this.isLoading = false,
    this.isImageUploading = false,
    this.isPosting = false,
    this.errorMessage,
    this.successMessage,
    this.titleLength = 0,
    this.contentLength = 0,
    this.postId,
    this.isEditMode = false,
  });

  WriteState copyWith({
    String? title,
    String? content,
    String? selectedCategory,
    WriteMode? selectedMode,
    List<File>? selectedImages,
    List<String>? uploadedImageUrls,
    bool? isLoading,
    bool? isImageUploading,
    bool? isPosting,
    String? errorMessage,
    String? successMessage,
    int? titleLength,
    int? contentLength,
    String? postId,
    bool? isEditMode,
  }) {
    return WriteState(
      title: title ?? this.title,
      content: content ?? this.content,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedImages: selectedImages ?? this.selectedImages,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
      isLoading: isLoading ?? this.isLoading,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      isPosting: isPosting ?? this.isPosting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      titleLength: titleLength ?? this.titleLength,
      contentLength: contentLength ?? this.contentLength,
      postId: postId ?? this.postId,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  bool get isTitleValid => title.trim().isNotEmpty && title.length <= 30;
  bool get isContentValid =>
      content.trim().isNotEmpty && content.length <= 1000;
  bool get isCategoryValid => selectedCategory.isNotEmpty;
  bool get isModeValid => selectedMode != null;
  bool get isFormValid =>
      isTitleValid &&
      isContentValid &&
      isCategoryValid &&
      isModeValid &&
      (selectedImages.isNotEmpty || uploadedImageUrls.isNotEmpty);
}

// 도메인 의존성을 콜백으로 주입
typedef CreatePost = Future<String> Function(Posts post);
typedef UploadImages = Future<List<String>> Function(List<File> files);

class WriteViewModel extends StateNotifier<WriteState> {
  final CreatePost _createPost;
  final UploadImages _uploadImages;
  final ImagePicker _imagePicker;
  final DeletePostUseCase _deletePostUseCase;
  final GetPostUseCase _getPostUseCase;
  final UpdatePostUseCase _updatePostUseCase;

  WriteViewModel({
    required CreatePost createPost,
    required UploadImages uploadImages,
    required ImagePicker imagePicker,
    required DeletePostUseCase deletePostUseCase,
    required GetPostUseCase getPostUseCase,
    required UpdatePostUseCase updatePostUseCase,
  }) : _createPost = createPost,
       _uploadImages = uploadImages,
       _imagePicker = imagePicker,
       _deletePostUseCase = deletePostUseCase,
       _getPostUseCase = getPostUseCase,
       _updatePostUseCase = updatePostUseCase,
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
      state = state.copyWith(selectedMode: m, errorMessage: null);

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

  // 게시글 삭제 메서드 추가
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await _deletePostUseCase.execute(postId, user.uid);

      state = state.copyWith(
        isLoading: false,
        successMessage: '게시글이 성공적으로 삭제되었습니다.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : '게시글 삭제 중 오류 발생: $e',
      );
    }
  }

  // 게시글 작성
  Future<void> createPost() async {
    if (!state.isFormValid) {
      state = state.copyWith(errorMessage: '제목, 내용, 카테고리, 모드, 이미지를 모두 입력해주세요.');
      return;
    }

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
      // Firestore에서 사용자의 닉네임과 프로필 이미지를 조회
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final nickname =
          userData?['nickname'] as String? ?? user.displayName ?? '익명';
      final profileImageUrl =
          userData?['profileImageUrl'] as String? ?? user.photoURL;

      List<String> urls = [];
      if (state.selectedImages.isNotEmpty) {
        state = state.copyWith(isImageUploading: true);
        urls = await _uploadImages(state.selectedImages);
        state = state.copyWith(
          isImageUploading: false,
          uploadedImageUrls: urls,
        );
      }

      final now = DateTime.now();
      final post = Posts(
        id: '',
        authorId: user.uid,
        author: Author(nickname: nickname, profileImageUrl: profileImageUrl),
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

      await _createPost(post);

      state = state.copyWith(
        isPosting: false,
        successMessage: '게시글이 성공적으로 작성되었습니다!',
      );
      _resetForm();
    } catch (e, st) {
      print('[Upload] failed: $e\n$st');
      state = state.copyWith(
        isPosting: false,
        isImageUploading: false,
        errorMessage: e.toString().isEmpty
            ? '알 수 없는 오류가 발생했습니다.'
            : e.toString(),
      );
    }
  }

  // 게시글 편집을 위해 기존 데이터를 불러오는 메서드
  Future<void> loadPostForEdit(String postId) async {
    state = state.copyWith(isLoading: true, isEditMode: true);
    try {
      final post = await _getPostUseCase.execute(postId);
      if (post == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '게시글을 찾을 수 없습니다.',
        );
        return;
      }
      state = state.copyWith(
        postId: post.id,
        title: post.title,
        content: post.content,
        selectedCategory: post.category,
        selectedMode: WriteMode.values.byName(post.mode),
        uploadedImageUrls: post.images,
        isLoading: false,
        titleLength: post.title.length,
        contentLength: post.content.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '게시글 불러오기 실패: $e');
    }
  }

  // 게시글 업데이트 메서드
  Future<void> updatePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return;
    }

    if (state.postId == null) {
      state = state.copyWith(errorMessage: '수정할 게시글 ID가 없습니다.');
      return;
    }

    if (!state.isFormValid) {
      state = state.copyWith(errorMessage: '모든 필드를 채워주세요.');
      return;
    }

    state = state.copyWith(isPosting: true);

    try {
      // Firestore에서 사용자의 닉네임과 프로필 이미지를 조회
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      final nickname =
          userData?['nickname'] as String? ?? user.displayName ?? '익명';
      final profileImageUrl =
          userData?['profileImageUrl'] as String? ?? user.photoURL;

      List<String> newImageUrls = state.uploadedImageUrls;
      if (state.selectedImages.isNotEmpty) {
        newImageUrls = await _uploadImages(state.selectedImages);
      }

      final updatedPost = Posts(
        id: state.postId!,
        authorId: user.uid,
        author: Author(nickname: nickname, profileImageUrl: profileImageUrl),
        category: state.selectedCategory,
        mode: state.selectedMode!.name,
        title: state.title.trim(),
        content: state.content.trim(),
        images: newImageUrls,
        stats: PostStats(likesCount: 0, commentsCount: 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reportCount: 0,
      );

      await _updatePostUseCase.execute(updatedPost, user.uid);

      state = state.copyWith(
        isPosting: false,
        successMessage: '게시글이 성공적으로 수정되었습니다!',
      );
    } catch (e) {
      state = state.copyWith(isPosting: false, errorMessage: e.toString());
    }
  }

  void _resetForm() => state = const WriteState();
  void saveDraft() => state = state.copyWith(successMessage: '임시저장되었습니다.');
  void clearErrorMessage() => state = state.copyWith(errorMessage: null);
  void clearSuccessMessage() => state = state.copyWith(successMessage: null);
}
