// lib/write/presentation/screens/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod import
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_sns/write/data/datasources/profile_mock_data.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/comment_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/post_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/tab_list_view.dart';
import 'widgets/profile_sliver_app_bar.dart';
import 'widgets/profile_tab_bar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
    final cs = theme.colorScheme;

    // Watch the userProfileProvider
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: userProfileAsync.when(
        data: (userProfile) {
          // Display the data once it's loaded
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ProfileSliverAppBar(
                  onEditPressed: () {
                    context.pushNamed('profile_edit');
                  },
                ),
                ProfileTabBar(tabController: _tabController),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                TabListView<Map<String, dynamic>>(
                  items: ProfileMockData.posts,
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
                // The rest of the TabListViews can stay the same for now
                TabListView<Map<String, dynamic>>(
                  items: ProfileMockData.comments,
                  emptyMessage: '아직 작성한 댓글이 없어요\n다른 사람의 글에 공감이나 팩폭을 남겨보세요!',
                  emptyIcon: Icons.chat_bubble_outline,
                  itemBuilder: (comment) => CommentCard(
                    content: comment['content'],
                    postTitle: comment['postTitle'],
                    date: comment['date'],
                  ),
                ),
                TabListView<Map<String, dynamic>>(
                  items: ProfileMockData.likes,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('프로필을 불러오는데 실패했습니다: $error')),
      ),
    );
  }
}
