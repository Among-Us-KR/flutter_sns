import '../entities/write.dart';
import '../repositories/write_repository.dart';

// 앱의 주요 동작(유즈케이스) 구현 (비즈니스 로직)

class GetWriteUseCase {
  final WriteRepository repository;

  GetWriteUseCase(this.repository);

  Future<Write> execute() {
    return repository.getWrite();
  }
}
