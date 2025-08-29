// 앱에서 발생하는 예외 정의 및 처리용 커스텀 예외 클래스

class WriteException implements Exception {
  final String message;
  WriteException(this.message);

  @override
  String toString() => 'WriteException: $message';
}
