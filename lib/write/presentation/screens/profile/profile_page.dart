import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comments_domain;
import 'package:flutter_sns/write/presentation/screens/profile/profile_page_view_model.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/comment_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/post_card.dart';
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/tab_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    final viewModel = ref.read(profileViewModelProvider(null).notifier);

    // 뷰모델 상태를 watch
    final profileState = ref.watch(profileViewModelProvider(null));

    // ✅ 위젯 빌드가 완료된 후에 데이터 로드 함수를 호출하도록 수정
    // 이 방법은 "Tried to modify a provider while the widget tree was building" 오류를 해결합니다.
    ref.listen<ProfileState>(profileViewModelProvider(null), (previous, next) {
      if (previous?.user == null && next.user != null) {
        viewModel.loadUserPosts();
        viewModel.loadUserLikedPosts();
        viewModel.loadUserComments();
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.errorMessage != null
          ? Center(
              child: Text('프로필을 불러오는데 실패했습니다: ${profileState.errorMessage}'),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  ProfileSliverAppBar(
                    actions: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings),
                        onSelected: (String result) async {
                          if (result == 'edit_profile') {
                            context.pushNamed('profile_edit');
                          } else if (result == 'logout') {
                            try {
                              // Firebase 로그아웃
                              await FirebaseAuth.instance.signOut();

                              // Google 로그아웃 (필요하다면)
                              final googleSignIn = GoogleSignIn();
                              await googleSignIn.signOut();
                              await googleSignIn.disconnect();

                              if (context.mounted) {
                                // 라우팅만 처리 (SnackBar는 생략하거나 login 페이지에서 띄우는 게 안정적)
                                ref.invalidate(
                                  profileViewModelProvider(null),
                                ); // 상태 초기화
                                context.goNamed('login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('로그아웃 실패: $e')),
                                );
                              }
                            }
                          } else if (result == 'delete_account') {
                            // TODO: 회원 탈퇴 기능 구현
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit_profile',
                                child: Text('프로필 편집'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Text('로그아웃'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete_account',
                                child: Text('회원 탈퇴'),
                              ),
                            ],
                      ),
                    ],
                  ),
                  ProfileTabBar(tabController: _tabController),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // 내가 쓴 글 목록
                  TabListView<Posts>(
                    items: profileState.userPosts,
                    emptyMessage: '아직 작성한 글이 없어요\n첫 번째 글을 던져보세요!',
                    emptyIcon: Icons.edit_note,
                    itemBuilder: (post) => PostCard(
                      // PostCard 위젯에 Posts 객체를 직접 전달
                      post: post,
                    ),
                  ),

                  // 내가 댓글 단 글 목록 (CommentCard 사용)
                  TabListView<comments_domain.Comments>(
                    items: profileState.userComments.values.toList(),
                    emptyMessage: '아직 작성한 댓글이 없어요\n다른 사람의 글에 공감이나 팩폭을 남겨보세요!',
                    emptyIcon: Icons.chat_bubble_outline,
                    itemBuilder: (comment) => CommentCard(
                      // CommentCard 위젯에 Comments 객체를 직접 전달
                      comment: comment,
                      postTitle:
                          profileState.userCommentedPostTitles[comment.id] ??
                          '게시글 제목을 불러올 수 없습니다',
                      onTap: () {
                        // 댓글을 누르면 해당 게시글로 이동하도록 로직 추가
                        context.pushNamed(
                          'post',
                          pathParameters: {'postId': comment.postId},
                        );
                      },
                    ),
                  ),
                  // 내가 좋아요 누른 글 목록
                  TabListView<Posts>(
                    items: profileState.userLikedPosts,
                    emptyMessage: '아직 공감한 글이 없어요\n마음에 드는 글에 공감을 눌러보세요!',
                    emptyIcon: Icons.favorite_outline,
                    itemBuilder: (post) => PostCard(
                      // PostCard 위젯에 Posts 객체를 직접 전달
                      post: post,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
