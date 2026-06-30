import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../posts/presentation/cubits/post_feed/post_feed_cubit.dart';
import '../../../posts/presentation/cubits/post_feed/post_feed_state.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/widgets/event_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostFeedCubit>().loadMorePosts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger when user scrolls to within 200px of the bottom
    return currentScroll >= (maxScroll - 200);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 0.5),
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.signIn);
              },
              child: const Text(
                'خروج',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBarAvatar(),
        title: Image.asset(
          'assets/images/logo_without_name.png',
          height: 42,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      body: BlocBuilder<PostFeedCubit, PostFeedState>(
        builder: (context, state) {
          if (state is PostFeedLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is PostFeedError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => context.read<PostFeedCubit>().loadPosts(),
                    child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          } else if (state is PostFeedLoaded) {
            final posts = state.posts;

            if (posts.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<PostFeedCubit>().loadPosts(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        'لا توجد منشورات بعد.\nشاركنا منشورك الأول اليوم!',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<PostFeedCubit>().loadPosts(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.hasReachedMax ? posts.length : posts.length + 1,
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  final item = posts[index];
                  if (item is PostEntity) {
                    return PostCard(post: item);
                  } else if (item is EventEntity) {
                    return EventCardWidget(
                      event: item,
                      onTap: () {
                        context.push('/events/${item.id}', extra: item);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          context.push(AppRoutes.createPost);
        },
        child: const Icon(Icons.add, color: AppColors.background, size: 28),
      ),
    );
  }
}
