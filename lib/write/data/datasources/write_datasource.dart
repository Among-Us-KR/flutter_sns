// Write 관련 API 호출 구현 (예: Firebase, REST API 등)

abstract class WriteDataSource {
  Future<String> fetchData();
}

class WriteDataSourceImpl implements WriteDataSource {
  @override
  Future<String> fetchData() async {
    // TODO: 실제 API 호출 구현
    return 'data from WriteDataSource';
  }
}
