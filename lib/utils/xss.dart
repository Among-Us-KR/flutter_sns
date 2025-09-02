// xss.dart
import 'dart:convert';
import 'package:flutter/services.dart';

/// XSS 및 악성 입력 필터 유틸리티
class XssFilter {
  // 금지어 리스트 (CSV로부터 로딩)
  static List<String> _bannedWords = [];

  /// CSV 파일에서 금지어 리스트 로드
  static Future<void> loadBannedWordsFromCSV() async {
    try {
      final csvString = await rootBundle.loadString('assets/banned_words/slang.csv');
      _bannedWords = LineSplitter.split(csvString)
          .map((line) => line.trim().toLowerCase())
          .where((line) => line.isNotEmpty)
          .toList();
      print('✅ 금지어 로드 완료: ${_bannedWords.length}개');
    } catch (e) {
      print('❌ 금지어 로드 실패: $e');
      _bannedWords = [];
    }
  }

  /// HTML 엔티티 직접 디코딩 (예: &lt; → <)
  static String decodeHtmlEntities(String input) {
    return input
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&#x3C;', '<')
        .replaceAll('&#x3E;', '>')
        .replaceAll('&#x60;', '`');
  }

  /// HTML 태그 제거 (예: <script>, <div> 등)
  static String removeHtmlTags(String input) {
    final htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return input.replaceAll(htmlTagRegExp, '');
  }

  /// 위험한 특수문자 제거 (예: <, >, ", ', ` )
  static String removeDangerousChars(String input) {
    final dangerousChars = ['<', '>', '"', '\'', '`'];
    var result = input;
    for (final ch in dangerousChars) {
      result = result.replaceAll(ch, '');
    }
    return result;
  }

  /// 금지어 포함 여부 확인
  static bool containsBannedWord(String input) {
    final lowerInput = input.toLowerCase();
    return _bannedWords.any((word) => lowerInput.contains(word));
  }

  /// 포함된 금지어 리스트 반환
  static List<String> getMatchedBannedWords(String input) {
    final lowerInput = input.toLowerCase();
    return _bannedWords.where((word) => lowerInput.contains(word)).toList();
  }

  /// XSS 필터링 전체 처리
  static String sanitize(String input) {
    var cleaned = input;

    // 1. HTML 인코딩 디코드
    cleaned = decodeHtmlEntities(cleaned);

    // 2. HTML 태그 제거
    cleaned = removeHtmlTags(cleaned);

    // 3. 위험한 특수문자 제거
    cleaned = removeDangerousChars(cleaned);

    // 4. 위험 키워드 제거
    final dangerousPatterns = [
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false), // onerror=, onclick= 등
      RegExp(r'alert\s*\(', caseSensitive: false),
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'script', caseSensitive: false),
      RegExp(r'document\.cookie', caseSensitive: false),
    ];

    for (final pattern in dangerousPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    return cleaned.trim();
  }

  /// sanitize + 금지어 체크 통합 결과 반환
  static Map<String, dynamic> secureInput(String input) {
    final sanitized = sanitize(input);
    final hasBanned = containsBannedWord(sanitized);
    final bannedWords = getMatchedBannedWords(sanitized);

    return {
      'original': input,
      'sanitized': sanitized,
      'hasBannedWord': hasBanned,
      'matchedWords': bannedWords,
    };
  }
}
