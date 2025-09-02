import 'package:flutter/material.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/post_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/top_tab_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    // SafeArea로 전체 화면을 감싸서 시스템 UI(상태 표시줄 등)와의 충돌을 방지합니다.
    return SafeArea(
      child: Column(
        children: [
          // 1. 상단 탭바
          const TopTabBar(),
          // -----------------
          // 2. 메인 콘텐츠 (이미지 피드)
          // -----------------
          // Expanded를 사용하여 PageView가 남은 공간을 모두 차지하도록 합니다.
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: PageView(
                scrollDirection: Axis.vertical,
                controller: controller,
                children: const <Widget>[
                  PostView(
                    postId: 'post_1', // 샘플 ID
                    // 이미지가 여러 장인 경우 (좌우 스와이프 가능)
                    imagePaths: [
                      'assets/images/cat_image.jpeg',
                      'assets/images/dog_image.jpeg',
                    ],
                    username: '화난강쥐',
                    caption: '내용내용내용내용내용내용내용내용내용내용내용내용내용내용..',
                    likeCount: 20,
                  ),
                  PostView(
                    postId: 'post_2', // 샘플 ID
                    imagePaths: [
                      'assets/images/dog_image.jpeg',
                    ], // 이미지가 한 장인 경우
                    username: '웃는강쥐',
                    caption: '오늘 날씨가 너무 좋아서 산책하고 왔어요! ',
                    likeCount: 152,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
