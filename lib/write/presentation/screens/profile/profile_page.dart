import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/core/providers/providers.dart';
import 'package:flutter_sns/write/core/services/account_service.dart';
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

    // 뷰모델 상태 watch
    final profileState = ref.watch(profileViewModelProvider(null));

    // ✅ 빌드 이후 데이터 로드
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
          ? Center(child: Text(profileState.errorMessage!))
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
                              await googleSignIn.signOut();
                              await googleSignIn.disconnect();

                              if (context.mounted) {
                                // 상태 초기화 + 로그인으로 이동
                                ref.invalidate(profileViewModelProvider(null));
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
                              barrierDismissible: !false,
                              builder: (context) {
                                bool isLoading = false;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
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
                                                    // 서버 회원탈퇴 호출
                                                    final msg =
                                                        await AccountService.deleteAccount(
                                                          context,
                                                        );

                                                    if (!context.mounted)
                                                      return;

                                                    // 다이얼로그 닫으며 성공 신호 전달
                                                    Navigator.of(
                                                      context,
                                                    ).pop(true);

                                                    // 다이얼로그 닫힌 뒤 스낵바 + 라우팅은 아래에서 처리
                                                    // (confirm == true 분기에서)
                                                  } catch (e) {
                                                    if (!context.mounted)
                                                      return;
                                                    // 실패 시 다이얼로그 내에서 토스트/스낵바 안내
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
                                                        () => isLoading = false,
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

                            // ✅ 다이얼로그에서 성공(true)로 닫힌 경우: 스낵바 → 로그인 이동
                            if (confirm == true && context.mounted) {
                              // 뷰모델/프로바이더 상태 초기화(선택)
                              ref.invalidate(profileViewModelProvider(null));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('회원 탈퇴가 완료되었습니다.'),
                                ),
                              );

                              // 로그인 화면으로 이동
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
                  // 내가 쓴 글 목록
                  TabListView<Posts>(
                    items: profileState.userPosts,
                    emptyMessage: '아직 작성한 글이 없어요\n첫 번째 글을 던져보세요!',
                    emptyIcon: Icons.edit_note,
                    itemBuilder: (post) => PostCard(post: post),
                  ),

                  // 내가 댓글 단 글 목록
                  TabListView<comments_domain.Comments>(
                    items: profileState.userComments.values.toList(),
                    emptyMessage: '아직 작성한 댓글이 없어요\n다른 사람의 글에 공감이나 팩폭을 남겨보세요!',
                    emptyIcon: Icons.chat_bubble_outline,
                    itemBuilder: (comment) => CommentCard(
                      comment: comment,
                      postTitle:
                          profileState.userCommentedPostTitles[comment.id] ??
                          '게시글 제목을 불러올 수 없습니다',
                      onTap: () {
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
                    itemBuilder: (post) => PostCard(post: post),
                  ),
                ],
              ),
            ),
    );
  }
}
