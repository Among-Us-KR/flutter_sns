import '../../domain/entities/write.dart';
import '../../domain/repositories/write_repository.dart';
import '../datasources/write_datasource.dart';

// 도메인 레이어에서 정의한 인터페이스 구현체 (데이터 조작)

class WriteRepositoryImpl implements WriteRepository {
  final WriteDataSource dataSource;

  WriteRepositoryImpl(this.dataSource);

  @override
  Future<Write> getWrite() async {
    // TODO: 데이터 변환, 캐싱 등 로직 추가
    final rawData = await dataSource.fetchData();
    // 예시: rawData를 Write 객체로 매핑 필요
    return Write(id: 1, name: rawData);
  }
}
