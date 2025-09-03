import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/data/datasources/firebase_post_datasource.dart';
import 'package:flutter_sns/write/data/datasources/firebase_user_datasource.dart';
import 'package:flutter_sns/write/data/repository/post_repository_impl.dart';
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/create_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/delete_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/get_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/update_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/upload_post_image_usecase.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

// Data Layer Providers 정의
final postDataSourceProvider = Provider<FirebasePostDataSource>((ref) {
  return FirebasePostDataSource();
});

final userDataSourceProvider = Provider<FirebaseUserDataSource>((ref) {
  return FirebaseUserDataSource();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final postDataSource = ref.watch(postDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);
  return PostRepositoryImpl(postDataSource, userDataSource);
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(ref.read(postRepositoryProvider));
});

final uploadImagesUseCaseProvider = Provider<UploadPostImagesUseCase>((ref) {
  return UploadPostImagesUseCase(ref.read(postRepositoryProvider));
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(ref.read(postRepositoryProvider));
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return DeletePostUseCase(repository);
});

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final getPostUseCaseProvider = Provider<GetPostUseCase>((ref) {
  return GetPostUseCase(ref.read(postRepositoryProvider));
});

final writeViewModelProvider =
    StateNotifierProvider<WriteViewModel, WriteState>((ref) {
      final postRepository = ref.read(postRepositoryProvider); // 게시글 생성/수정/삭제용
      final imagePicker = ImagePicker();
      final deletePostUseCase = ref.read(deletePostUseCaseProvider);
      final getPostUseCase = ref.read(getPostUseCaseProvider);
      final updatePostUseCase = ref.read(updatePostUseCaseProvider);

      return WriteViewModel(
        createPost: postRepository.createPost,
        uploadImages: postRepository.uploadImages,
        imagePicker: imagePicker,
        deletePostUseCase: deletePostUseCase,
        getPostUseCase: getPostUseCase, // 주입
        updatePostUseCase: updatePostUseCase, // 주입
      );
    });

/// 편의용 Computed Providers
final canPostProvider = Provider<bool>((ref) {
  final state = ref.watch(writeViewModelProvider);
  return state.isFormValid && !state.isPosting;
});

final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(writeViewModelProvider);
  return state.isLoading || state.isImageUploading || state.isPosting;
});

final selectedImagesCountProvider = Provider<int>((ref) {
  final state = ref.watch(writeViewModelProvider);
  return state.selectedImages.length;
});

final availableCategoriesProvider = Provider<List<String>>((ref) {
  // WriteState.categories 대신 전역 변수를 참조
  return categories;
});
