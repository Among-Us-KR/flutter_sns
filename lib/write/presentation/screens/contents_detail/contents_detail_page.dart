import 'package:flutter/material.dart';
import 'package:flutter_sns/theme/theme.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_input.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/post_contents_view.dart';
import 'package:flutter_sns/write/presentation/screens/home/widgets/no_glow_scroll_behavior.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/comment_section_view.dart';

class ContentsDetailPage extends StatelessWidget {
  const ContentsDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 스크롤 시 앱바 색상이 변하는 것을 방지
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text('Post #$postId'), // postId를 사용하여 제목 표시
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      // ScrollConfiguration을 사용하여 스크롤 시 파란색 Glow 효과를 제거
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: ListView(
          children: const [
            // 1. 게시물 본문 위젯
            PostContentView(), // 분리된 게시물 내용 위젯
            // 2. 구분선
            Divider(height: 1, thickness: 1, color: AppColors.n300),

            // 3. 댓글 목록 위젯
            CommentSectionView(), // 분리된 댓글 목록 위젯
          ],
        ),
      ),
      // 4. 하단 댓글 입력창 위젯
      bottomNavigationBar: const CommentInputField(), // 분리된 댓글 입력창 위젯
    );
  }

  /// 점 세개 아이콘을 눌렀을 때 표시되는 하단 메뉴(Bottom Sheet)
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext bottomSheetContext) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: Text(
                  '편집하기',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.brand),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext); // 바텀 시트 닫기
                  // TODO: 편집 페이지로 이동하는 로직 구현
                },
              ),
              ListTile(
                title: Text('삭제하기', style: textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(bottomSheetContext); // 바텀 시트 닫기
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 게시물 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            '정말로 삭제하시겠습니까?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '이 게시물을 삭제하면 복원할 수 없습니다.',
            style: AppTypography.body(AppColors.n600),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소', style: TextStyle(color: AppColors.n900)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // TODO: 실제 게시물 삭제 로직 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.n900,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
