import '../entities/write.dart';

// 추상화된 저장소 인터페이스 정의

abstract class WriteRepository {
  Future<Write> getWrite();
}
