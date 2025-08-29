// // 상태관리 (예: Riverpod, Provider 등) 예시

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/usecases/get_write_usecase.dart';

// final write_provider = FutureProvider.autoDispose((ref) async {
//   final usecase = ref.read(getWriteUseCaseProvider);
//   return await usecase.execute();
// });
