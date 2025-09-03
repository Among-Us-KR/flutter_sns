import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/data/datasources/firebase_post_datasource.dart';
import 'package:flutter_sns/write/data/repository/post_repository_impl.dart';
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/create_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/delete_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/update_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/upload_post_image_usecase.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

/// Data Layer Providers
final firebasePostDataSourceProvider = Provider<FirebasePostDataSource>((ref) {
  return FirebasePostDataSource();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.read(firebasePostDataSourceProvider));
});

/// Domain Layer Providers (UseCases)
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
  return DeletePostUseCase(ref.read(postRepositoryProvider));
});

/// Utility Providers
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

/// Presentation Layer Providers
final writeViewModelProvider =
    StateNotifierProvider<WriteViewModel, WriteState>((ref) {
      final createPost = ref.read(createPostUseCaseProvider).execute;
      final uploadImages = ref.read(uploadImagesUseCaseProvider).execute;
      final imagePicker = ref.read(imagePickerProvider);

      return WriteViewModel(
        createPost: createPost,
        uploadImages: uploadImages,
        imagePicker: imagePicker,
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
