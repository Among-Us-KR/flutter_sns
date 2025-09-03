import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadState {
  final bool isLoading;
  final String? uploadedImageUrl;

  UploadState({this.isLoading = false, this.uploadedImageUrl});
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier() : super(UploadState());

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadProfileImage(String uid, File file) async {
    final fileName = file.path.split('/').last;

    // 허용 확장자 확인
    if (!fileName.toLowerCase().matches(RegExp(r'.*\.(jpg|jpeg|png|gif)$'))) {
      throw Exception('허용되지 않은 파일 형식입니다.');
    }

    state = UploadState(isLoading: true);

    try {
      final ref = _storage.ref().child('user_profiles/$uid/$fileName');
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      state = UploadState(isLoading: false, uploadedImageUrl: url);
    } catch (e) {
      state = UploadState(isLoading: false);
      rethrow;
    }
  }
}

// Riverpod provider
final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  return UploadNotifier();
});

// extension for RegExp matching
extension StringMatch on String {
  bool matches(RegExp regExp) => regExp.hasMatch(this);
}