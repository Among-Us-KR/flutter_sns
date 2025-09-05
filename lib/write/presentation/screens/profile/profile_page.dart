import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/core/services/account_service.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comments_domain;
import 'package:flutter_sns/write/presentation/screens/profile/tab_list/tab_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'widgets/profile_sliver_app_bar.dart';
import 'widgets/profile_tab_bar.dart';
import 'tab_list/post_card.dart';
import 'tab_list/comment_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ─────────────────────────────
  // 외부(탭 전환 시)에서 호출할 공개 메서드
  // router/bottom nav 쪽에서 profileTabKey.currentState?.refresh();
  // ─────────────────────────────
  Future<void> refresh() => _refreshAll();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 당겨서 새로고침/탭 진입 갱신 공용 함수
  Future<void> _refreshAll() async {
    final vm = ref.read(profileViewModelProvider(null).notifier);
    // 프로필 로드 후 각 리스트를 로드하도록 순서를 보장합니다.
    await vm.loadCurrentUser();
    await Future.wait([
      vm.loadUserPosts(),
      vm.loadUserLikedPosts(),
      vm.loadUserComments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final viewModel = ref.read(profileViewModelProvider(null).notifier);

    // 상태 watch
    final profileState = ref.watch(profileViewModelProvider(null));

    return Scaffold(
      backgroundColor: cs.surface,

      // ✅ 화면 전체 당겨서 새로고침
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        // NestedScrollView 상단에서만 동작하도록
        notificationPredicate: (notification) => notification.depth == 0,
        child: profileState.isLoading
            ? ListView(
                // RefreshIndicator는 스크롤러 필요
                children: [
                  const SizedBox(height: 60),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 60),
                ],
              )
            : profileState.errorMessage != null
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(profileState.errorMessage!),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _refreshAll,
                    child: const Text('다시 시도'),
                  ),
                ],
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

                                // Google 로그아웃 (필요 시)
                                final googleSignIn = GoogleSignIn();
                                try {
                                  await googleSignIn.signOut();
                                  await googleSignIn.disconnect();
                                } catch (_) {
                                  // 이미 연결 해제된 상태면 무시
                                }

                                if (context.mounted) {
                                  // 상태 초기화 + 로그인으로 이동
                                  ref.invalidate(
                                    profileViewModelProvider(null),
                                  );
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
                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  bool isLoading = false;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '회원 탈퇴',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          '정말 탈퇴하시겠습니까?\n\n'
                                          '회원님의 모든 데이터(프로필, 게시글, 댓글, 좋아요, 업로드한 이미지)가 '
                                          '영구적으로 삭제되며 복구할 수 없습니다.',
                                          style: TextStyle(height: 1.4),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('취소'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    setState(
                                                      () => isLoading = true,
                                                    );
                                                    try {
                                                      await AccountService.deleteAccount(
                                                        context,
                                                      );
                                                      if (!context.mounted)
                                                        return;
                                                      Navigator.of(
                                                        context,
                                                      ).pop(true);
                                                    } catch (e) {
                                                      if (!context.mounted)
                                                        return;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '회원 탈퇴 실패: $e',
                                                          ),
                                                        ),
                                                      );
                                                    } finally {
                                                      if (context.mounted) {
                                                        setState(
                                                          () =>
                                                              isLoading = false,
                                                        );
                                                      }
                                                    }
                                                  },
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Text('탈퇴하기'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );

                              // ✅ 성공 시 상태 초기화 & 라우팅
                              if (confirm == true && context.mounted) {
                                ref.invalidate(profileViewModelProvider(null));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('회원 탈퇴가 완료되었습니다.'),
                                  ),
                                );
                                context.goNamed('login');
                              }
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
                    // 내가 쓴 글
                    TabListView<Posts>(
                      items: profileState.userPosts,
                      emptyMessage: '아직 작성한 글이 없어요\n첫 번째 글을 던져보세요!',
                      emptyIcon: Icons.edit_note,
                      itemBuilder: (post) => PostCard(
                        post: post,
                        onTap: () {
                          context.pushNamed(
                            'post_detail',
                            pathParameters: {'postId': post.id},
                          );
                        },
                      ),
                      onRefresh: _refreshAll,
                    ),

                    // // 내가 댓글 단 글
                    // TabListView<comments_domain.Comments>(
                    //   items: profileState.userComments.values.toList(),
                    //   emptyMessage: '아직 작성한 댓글이 없어요\n다른 사람의 글에 공감이나 팩폭을 남겨보세요!',
                    //   emptyIcon: Icons.chat_bubble_outline,
                    //   itemBuilder: (comment) => CommentCard(
                    //     comment: comment,
                    //     postTitle:
                    //         profileState.userCommentedPostTitles[comment.id] ??
                    //         '게시글 제목을 불러올 수 없습니다',
                    //     onTap: () {
                    //       // 🔧 라우트 이름 수정: 'post' → 'post_detail'
                    //       context.pushNamed(
                    //         'post_detail',
                    //         pathParameters: {'postId': comment.postId},
                    //       );
                    //     },
                    //   ),
                    //   onRefresh: _refreshAll,
                    // ),

                    // 내가 좋아요 누른 글
                    TabListView<Posts>(
                      items: profileState.userLikedPosts,
                      emptyMessage: '아직 공감한 글이 없어요\n마음에 드는 글에 공감을 눌러보세요!',
                      emptyIcon: Icons.favorite_outline,
                      itemBuilder: (post) => PostCard(
                        post: post,
                        onTap: () {
                          context.pushNamed(
                            'post_detail',
                            pathParameters: {'postId': post.id},
                          );
                        },
                      ),
                      onRefresh: _refreshAll,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
