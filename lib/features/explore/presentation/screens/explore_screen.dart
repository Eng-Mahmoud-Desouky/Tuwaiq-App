import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';
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
    context.read<ExploreCubit>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_without_name.png',
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
                  hintText: 'ابحث عن منشورات أو حسابات...',
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
            
            // Search Placeholder Content
            Expanded(
              child: BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  final query = state is ExploreSearchQueryChanged ? state.query : '';
                  
                  if (query.isEmpty) {
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
                  
                  // If query is not empty, show search results placeholder (no database query is made)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.manage_search_rounded,
                            size: 72,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'البحث عن "$query"',
                            style: AppTextStyles.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سيتم عرض نتائج البحث هنا فور توفر الفهرسة الشاملة للمحتوى.',
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
