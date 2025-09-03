class NicknamePolicy {
  static const int minLen = 2;
  static const int maxLen = 10;
  // 한글/영문/숫자/밑줄만 허용 (공백, 특수문자 X)
  static final RegExp allowed = RegExp(r'^[a-zA-Z0-9가-힣_]+$');
  static const List<String> reserved = [
    'admin',
    'administrator',
    'root',
    'system',
    '운영자',
    '관리자',
    '던져',
  ];

  /// 문제가 없으면 null, 있으면 에러 메시지 반환
  static String? validate(String raw) {
    final v = raw.trim();

    if (v.isEmpty) return '닉네임을 입력해주세요.';
    if (v.length < minLen) return '닉네임은 최소 $minLen자 이상이어야 해요.';
    if (v.length > maxLen) return '닉네임은 최대 $maxLen자까지 가능해요.';
    if (!allowed.hasMatch(v)) return '한글/영문/숫자/(_)만 사용할 수 있어요.';
    if (reserved.contains(v.toLowerCase())) return '사용할 수 없는 닉네임이에요.';
    return null;
  }

  /// 중복 체크용 정규화 (DB에는 항상 소문자 저장)
  static String normalizedLower(String raw) => raw.trim().toLowerCase();
}
