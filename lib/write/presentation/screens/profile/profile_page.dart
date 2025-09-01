import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/profile_header.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/stats_item.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/tab_list/comment_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/tab_list/post_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/widgets/tab_list/tab_list_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static const double statsOverflow = 80;

  // 임시 데이터 (나중에 ViewModel에서 가져올 예정)
  final List<Map<String, dynamic>> _posts = [
    {
      'title': '타이틀타이틀타이틀타이틀타이틀..',
      'content': '내용내용내용내용내용내용내용내용\n내용내용내용내용내용내용내용내용...',
      'category': '멍청스',
      'mode': 'punch',
      'imageUrl': 'https://picsum.photos/100/100',
      'date': '2025-08-28 19:00',
      'commentCount': 10,
    },
    {
      'title': '오늘 정말 힘든 하루였어요',
      'content': '회사에서 일이 너무 많아서 스트레스 받네요...',
      'category': '대박스',
      'mode': 'empathy',
      'imageUrl': 'https://picsum.photos/100/100',
      'date': '2025-08-27 22:15',
      'commentCount': 3,
    },
  ];

  final List<Map<String, dynamic>> _comments = [
    {
      'content': '정말 공감되는 글이네요! 저도 비슷한 경험이 있어요.',
      'postTitle': '오늘 하루 정말 힘들었다...',
      'date': '2025-08-28 20:30',
    },
    {
      'content': '그건 좀 아닌 것 같은데요? 다시 생각해보세요.',
      'postTitle': '이런 생각 어때요?',
      'date': '2025-08-27 18:45',
    },
  ];

  final List<Map<String, dynamic>> _likes = [
    // {
    //   'title': '오늘 점심 뭐 먹지? 고민되네...',
    //   'content': '회사 근처 맛집 추천 좀 해주세요 ㅠㅠ',
    //   'category': '고민스',
    //   'mode': 'empathy',
    //   'imageUrl': 'https://picsum.photos/100/100',
    //   'date': '2025-08-28 12:30',
    //   'commentCount': 5,
    // },
    // {
    //   'title': '월요일이 이렇게 힘들 줄이야',
    //   'content': '주말이 너무 짧아... 다시 월요일이라니',
    //   'category': '슬픈스',
    //   'mode': 'empathy',
    //   'imageUrl': 'https://picsum.photos/100/100',
    //   'date': '2025-08-26 09:15',
    //   'commentCount': 23,
    // },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text('프로필', style: theme.textTheme.headlineLarge),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // 프로필 편집 페이지로 이동
                // TODO: 현재 사용자 정보 넘기기(닉네임, 프로필이미지)
                context.go('/profile/edit');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                minimumSize: const Size(41, 30),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                '수정',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  color: colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: const ProfileHeader(),
                ),
                // 통계 섹션
                Positioned(
                  bottom: -statsOverflow * 0.8,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      //TODO: Firebase에서 받아온 숫자로 변경
                      children: [
                        Expanded(child: StatsItem(count: 7, label: '던진 글')),
                        SizedBox(width: 7),
                        Expanded(child: StatsItem(count: 32, label: '받은 공감')),
                        SizedBox(width: 7),
                        Expanded(child: StatsItem(count: 14, label: '받은 팩폭')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: statsOverflow * 0.9),

          // 탭 바
          Container(
            color: colorScheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: TabBar(
                controller: _tabController,
                dividerHeight: 0,
                labelColor: colorScheme.primary,
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                unselectedLabelStyle: theme.textTheme.titleMedium,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: colorScheme.primary),
                  insets: EdgeInsets.zero,
                ),
                tabs: const [
                  Tab(height: 32, child: Text('내 글')),
                  Tab(height: 32, child: Text('내 댓글')),
                  Tab(height: 32, child: Text('내 공감')),
                ],
              ),
            ),
          ),

          // 탭 뷰 내용
          //TODO: 클릭 시 해당 글로 이동하도록 수정 필요
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 내 글 탭
                TabListView<Map<String, dynamic>>(
                  items: _posts,
                  emptyMessage: '아직 작성한 글이 없어요\n첫 번째 글을 던져보세요!',
                  emptyIcon: Icons.edit_note,
                  itemBuilder: (post) => PostCard(
                    title: post['title'],
                    content: post['content'],
                    category: post['category'],
                    mode: post['mode'],
                    imageUrl: post['imageUrl'],
                    date: post['date'],
                    commentCount: post['commentCount'],
                  ),
                ),

                // 내 댓글 탭
                TabListView<Map<String, dynamic>>(
                  items: _comments,
                  emptyMessage: '아직 작성한 댓글이 없어요\n다른 사람의 글에 공감이나 팩폭을 남겨보세요!',
                  emptyIcon: Icons.chat_bubble_outline,
                  itemBuilder: (comment) => CommentCard(
                    content: comment['content'],
                    postTitle: comment['postTitle'],
                    date: comment['date'],
                  ),
                ),

                // 내 공감 탭
                TabListView<Map<String, dynamic>>(
                  items: _likes,
                  emptyMessage: '아직 공감한 글이 없어요\n마음에 드는 글에 공감을 눌러보세요!',
                  emptyIcon: Icons.favorite_outline,
                  itemBuilder: (like) => PostCard(
                    title: like['title'],
                    content: like['content'],
                    category: like['category'],
                    mode: like['mode'],
                    imageUrl: like['imageUrl'],
                    date: like['date'],
                    commentCount: like['commentCount'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
