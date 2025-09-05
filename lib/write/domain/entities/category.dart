enum Category {
  all,
  fool, // 멍청스
  worry, // 고민스
  awesome, // 대박스
  happy, // 행복스
  sad, // 슬펐스
  angry, // 빡쳤스
  surprised, // 놀랐스
  honest, // 솔직스
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.all:
        return '전체';
      case Category.fool:
        return '멍청스';
      case Category.worry:
        return '고민스';
      case Category.awesome:
        return '대박스';
      case Category.happy:
        return '행복스';
      case Category.sad:
        return '슬펐스';
      case Category.angry:
        return '빡쳤스';
      case Category.surprised:
        return '놀랐스';
      case Category.honest:
        return '솔직스';
    }
  }
}
