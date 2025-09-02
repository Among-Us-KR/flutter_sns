import 'package:flutter/material.dart';

/// 스크롤 시 나타나는 오버스크롤 효과(주황색/파란색 그림자)를 제거하는 동작
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
