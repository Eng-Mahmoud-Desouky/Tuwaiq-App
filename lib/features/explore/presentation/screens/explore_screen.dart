import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'الكل',
    'مواسم ومهرجانات',
    'حفلات ومهرجانات',
    'رياضة ومغامرات',
    'فنون وثقافة',
    'محاضرات وورش عمل',
    'طعام وترفيه',
    'معارض ومؤتمرات',
    'فعاليات مجتمعية',
    'أخرى',
  ];

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
    context.read<ExploreCubit>().searchEvents(_searchController.text);
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'الكل': return '🌟';
      case 'حفلات ومهرجانات': return '🎵';
      case 'رياضة ومغامرات': return '⚽';
      case 'فنون وثقافة': return '🎨';
      case 'محاضرات وورش عمل': return '💡';
      case 'طعام وترفيه': return '🍽️';
      case 'مواسم ومهرجانات': return '🎪';
      case 'معارض ومؤتمرات': return '💼';
      case 'فعاليات مجتمعية': return '🤝';
      case 'أخرى': return '🏷️';
      default: return '📍';
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final days = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    
    final weekdayStr = days[dateTime.weekday % 7];
    final day = dateTime.day;
    final monthStr = months[dateTime.month - 1];
    
    return '$weekdayStr، $day $monthStr';
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
        actions: const [],
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<ExploreCubit>().loadEvents(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Title & Search Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'اكتشف الفعاليات',
                    style: AppTextStyles.displayLgMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن فعاليات...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            // Horizontal Categories Chips
            SliverToBoxAdapter(
              child: BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  final selectedCategory = state is ExploreLoaded
                      ? state.selectedCategory
                      : 'الكل';

                  return Container(
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = selectedCategory == category;
                        final emoji = _getCategoryEmoji(category);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () {
                              context.read<ExploreCubit>().selectCategory(category);
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$category $emoji',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: isSelected
                                        ? AppColors.background
                                        : AppColors.primary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Events List Section
            BlocBuilder<ExploreCubit, ExploreState>(
              builder: (context, state) {
                if (state is ExploreLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is ExploreError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppTextStyles.bodyLg,
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
                            onPressed: () =>
                                context.read<ExploreCubit>().loadEvents(),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ExploreLoaded) {
                  final events = state.filteredEvents;

                  if (events.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_busy_outlined,
                              size: 72,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد فعاليات مطابقة لبحثك',
                              style: AppTextStyles.titleSm.copyWith(
                                color: AppColors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'جرب تغيير تصنيف البحث أو مسح النص المكتوب',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (_searchController.text.isNotEmpty ||
                                state.selectedCategory != 'الكل')
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ExploreCubit>()
                                      .selectCategory('الكل');
                                },
                                child: const Text(
                                  'عرض الكل',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'فعاليات بالقرب منك',
                            style: AppTextStyles.titleSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Scrollable Grid of Event Cards
            BlocBuilder<ExploreCubit, ExploreState>(
              builder: (context, state) {
                if (state is ExploreLoaded && state.filteredEvents.isNotEmpty) {
                  final events = state.filteredEvents;

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          return _buildEventCard(context, event);
                        },
                        childCount: events.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            
            // Safe bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventEntity event) {
    return GestureDetector(
      onTap: () {
        context.push('/events/${event.id}', extra: event);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  event.coverUrl != null && event.coverUrl!.isNotEmpty
                      ? Image.network(
                          event.coverUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: AppColors.outline,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(
                            Icons.event_available_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                ],
              ),
            ),

            // Card Body (Event Info)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Location name
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.city.isNotEmpty
                              ? '${event.city}، ${event.locationName}'
                              : event.locationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.outlineVariant.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),

                  // Bottom row with category chip only (excluding payment/price tags as requested)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tuwaiqGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${event.category} ${_getCategoryEmoji(event.category)}',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.tuwaiqGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Region/City badge
                      if (event.region.isNotEmpty)
                        Text(
                          event.region,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
