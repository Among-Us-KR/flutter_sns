import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/data/datasources/firebase_post_datasource.dart';
import 'package:flutter_sns/write/data/datasources/firebase_storage_datasource.dart';
import 'package:flutter_sns/write/data/datasources/firebase_user_datasource.dart';
import 'package:flutter_sns/write/data/datasources/user_datasource.dart';
import 'package:flutter_sns/write/data/repository/post_repository_impl.dart';
import 'package:flutter_sns/write/data/repository/users_repository_impl.dart';
import 'package:flutter_sns/write/domain/entities/category.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/create_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/delete_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/get_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/update_post_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/post_usecase/upload_post_image_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/check_nickname_duplicate_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/get_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_profile_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/update_user_stats_usecase.dart';
import 'package:flutter_sns/write/domain/usecases/profile_usecase/upload_profile_image_usecase.dart';
import 'package:flutter_sns/write/presentation/screens/profile/profile_page_view_model.dart';
import 'package:flutter_sns/write/presentation/screens/write/write_page_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

// Firebase 서비스 프로바이더
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

// 데이터 소스 프로바이더
final userDataSourceProvider = Provider<UserDatasource>(
  (ref) => FirebaseUserDatasource(firestore: ref.watch(firestoreProvider)),
);
final postDataSourceProvider = Provider<FirebasePostDataSource>((ref) {
  return FirebasePostDataSource(firestore: ref.watch(firestoreProvider));
});
final firebaseStorageDataSourceProvider = Provider<FirebaseStorageDataSource>(
  (ref) => FirebaseStorageDataSource(),
);

// 레포지토리 프로바이더
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final postDataSource = ref.watch(postDataSourceProvider);
  final userDataSource = ref.watch(userDataSourceProvider);
  return PostRepositoryImpl(postDataSource, userDataSource);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    ref.watch(userDataSourceProvider),
    ref.watch(firebaseStorageDataSourceProvider),
    ref.watch(firestoreProvider),
  );
});

// UseCase 프로바이더
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

final getPostUseCaseProvider = Provider<GetPostUseCase>((ref) {
  return GetPostUseCase(ref.read(postRepositoryProvider));
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return GetUserProfileUseCase(repo);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUserProfileUseCase(repo);
});

final updateUserStatsUseCaseProvider = Provider<UpdateUserStatsUseCase>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUserStatsUseCase(repo);
});

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>((
  ref,
) {
  final repo = ref.watch(userRepositoryProvider);
  return UploadProfileImageUseCase(repo);
});

final checkNicknameDuplicateUseCaseProvider =
    Provider<CheckNicknameDuplicateUseCase>((ref) {
      final repo = ref.watch(userRepositoryProvider);
      return CheckNicknameDuplicateUseCase(repo);
    });

// 뷰모델 프로바이더
final writeViewModelProvider =
    StateNotifierProvider<WriteViewModel, WriteState>((ref) {
      final postRepository = ref.read(postRepositoryProvider);
      final imagePicker = ImagePicker();
      final deletePostUseCase = ref.read(deletePostUseCaseProvider);
      final getPostUseCase = ref.read(getPostUseCaseProvider);
      final updatePostUseCase = ref.read(updatePostUseCaseProvider);

      return WriteViewModel(
        createPost: postRepository.createPost,
        uploadImages: postRepository.uploadImages,
        imagePicker: imagePicker,
        deletePostUseCase: deletePostUseCase,
        getPostUseCase: getPostUseCase,
        updatePostUseCase: updatePostUseCase,
      );
    });

final profileViewModelProvider =
    StateNotifierProvider.family<ProfileViewModel, ProfileState, String?>((
      ref,
      uid,
    ) {
      final vm = ProfileViewModel(
        getUserProfile: ref.watch(getUserProfileUseCaseProvider),
        updateUserStats: ref.watch(updateUserStatsUseCaseProvider),
        postRepository: ref.watch(postRepositoryProvider), // 이 줄이 추가되었습니다.
      );
      if (uid == null) {
        Future.microtask(() => vm.loadCurrentUser());
      } else {
        Future.microtask(() => vm.loadByUid(uid));
      }

      ref.listen<AsyncValue<domain.UserStats>>(userStatsProvider, (
        previousStats,
        newStats,
      ) {
        if (newStats.hasValue) {
          vm.updateStatsFromStream(newStats.value!);
        }
      });

      return vm;
    });

// 데이터 바인딩용 프로바이더 (UI가 직접 watch)
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw Exception('로그인된 사용자가 없습니다.');
  }
  return user.uid;
});

final userProfileProvider = FutureProvider.autoDispose<domain.User>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserProfile(userId);
});

final userStatsProvider = StreamProvider.autoDispose<domain.UserStats>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) {
    return Stream.value(const domain.UserStats());
  }

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStatsStream(uid);
});

// 기타 편의용 Computed Providers
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
  return Category.values.map((category) => category.displayName).toList();
});
