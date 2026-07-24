import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ExploreCubit>().onSearchTextChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo.png',
            height: 42,
            fit: BoxFit.contain,
          ),
          leading: const AppBarAvatar(),
          shape: const Border(
            bottom: BorderSide(
              color: AppColors.outline,
              width: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'ابحث في SCRATCH...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.secondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.secondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.secondary),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.outline,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Tabs Section (Visible only when searching)
              BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  if (state is ExploreInitial) {
                    return const SizedBox.shrink();
                  }
                  return const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.secondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.0,
                    tabs: [
                      Tab(text: 'المنشورات'),
                      Tab(text: 'الحسابات'),
                    ],
                  );
                },
              ),
              
              // Body Content
              Expanded(
                child: BlocBuilder<ExploreCubit, ExploreState>(
                  builder: (context, state) {
                    if (state is ExploreInitial) {
                      return _buildInitialSearchPlaceholder();
                    } else if (state is ExploreSearchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is ExploreSearchLoaded) {
                      return TabBarView(
                        children: [
                          _buildPostsTab(context, state),
                          _buildAccountsTab(context, state),
                        ],
                      );
                    } else if (state is ExploreSearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialSearchPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 72,
              color: AppColors.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث في SCRATCH',
              style: AppTextStyles.titleMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اكتب كلمات مفتاحية للبحث عن منشورات الأعضاء أو معرفات الحسابات الخاصة بهم.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.secondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context, ExploreSearchLoaded state) {
    if (state.posts.isEmpty) {
      return Center(
        child: Text(
          'لا توجد منشورات تطابق البحث',
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          context.read<ExploreCubit>().loadMorePosts();
        }
        return false;
      },
      child: ListView.builder(
        key: const PageStorageKey('search_posts'),
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.posts.length + (state.isLoadingMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          return PostCard(post: state.posts[index]);
        },
      ),
    );
  }

  Widget _buildAccountsTab(BuildContext context, ExploreSearchLoaded state) {
    if (state.accounts.isEmpty) {
      return Center(
        child: Text(
          'لا توجد حسابات تطابق البحث',
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          context.read<ExploreCubit>().loadMoreAccounts();
        }
        return false;
      },
      child: ListView.builder(
        key: const PageStorageKey('search_accounts'),
        padding: const EdgeInsets.all(16.0),
        itemCount: state.accounts.length + (state.isLoadingMoreAccounts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.accounts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          
          final user = state.accounts[index];
          return Card(
            color: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline, width: 0.5),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.push(AppRoutes.profile, extra: user.id),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHighest,
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: user.avatarUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 150,
                                memCacheHeight: 150,
                                placeholder: (context, url) => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildDefaultAvatar(user.fullName),
                              )
                            : _buildDefaultAvatar(user.fullName),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      color: AppColors.surfaceContainerHighest,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
