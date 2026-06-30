import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/event_details_cubit.dart';
import '../cubit/event_details_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final EventEntity? initialEvent;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
    context.read<EventDetailsCubit>().loadEvent(widget.eventId, currentUserId);
  }

  Future<void> _openGoogleMaps(String urlString) async {
    final url = Uri.tryParse(urlString);
    if (url != null) {
      try {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          context.showSnackBar('تعذر فتح رابط الخريطة', isError: true);
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(
            'رابط الخريطة غير صالح أو غير معتمد',
            isError: true,
          );
        }
      }
    } else {
      context.showSnackBar('رابط الموقع غير متوفر', isError: true);
    }
  }

  String _formatFullDateTime(DateTime dateTime) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month $year | الساعة $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<EventDetailsCubit, EventDetailsState>(
        builder: (context, state) {
          if (state is EventDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is EventDetailsError) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ أثناء تحميل الفعالية',
                          style: AppTextStyles.titleSm.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'إعادة المحاولة',
                          width: 200,
                          onPressed: () {
                            final authState = context.read<AuthCubit>().state;
                            final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
                            context.read<EventDetailsCubit>().loadEvent(
                              widget.eventId,
                              currentUserId,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is EventDetailsLoaded) {
            final event = state.event;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                slivers: [
                  // App Bar with Hero Cover Image
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      BlocBuilder<EventDetailsCubit, EventDetailsState>(
                        builder: (context, state) {
                          if (state is EventDetailsLoaded) {
                            final authState = context.read<AuthCubit>().state;
                            final currentUserId =
                                (authState is AuthSuccess) ? authState.user.id : '';
                            final isOwnEvent =
                                state.event.creatorId == currentUserId;
                            if (isOwnEvent) return const SizedBox.shrink();

                            return IconButton(
                              icon: Icon(
                                state.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (currentUserId.isNotEmpty) {
                                  context
                                      .read<EventDetailsCubit>()
                                      .toggleSave(currentUserId);
                                } else {
                                  context.showSnackBar(
                                    'يرجى تسجيل الدخول لحفظ الفعاليات',
                                    isError: true,
                                  );
                                }
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          event.coverUrl != null && event.coverUrl!.isNotEmpty
                              ? Image.network(
                                  event.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.surfaceContainerHigh,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          size: 64,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Icon(
                                    Icons.event_available_outlined,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                ),
                          // Shadow overlay on image
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Event Info Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Chip & Region Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  event.category,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (event.region.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.region,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
 
                          // Event Title
                          Text(
                            event.title,
                            style: AppTextStyles.headlineMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
 
                          // Date Card
                          _buildDetailCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'موعد الفعالية',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTimeRow(
                                  label: 'يبدأ في:',
                                  value: _formatFullDateTime(event.startDate),
                                ),
                                const SizedBox(height: 10),
                                _buildTimeRow(
                                  label: 'ينتهي في:',
                                  value: _formatFullDateTime(event.endDate),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
 
                          // Location Card
                          _buildDetailCard(
                            icon: Icons.location_on_outlined,
                            title: 'تفاصيل الموقع',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  event.city.isNotEmpty || event.region.isNotEmpty
                                      ? '${event.city}${event.city.isNotEmpty && event.region.isNotEmpty ? '، ' : ''}${event.region}'
                                      : 'فعالية أونلاين',
                                  style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                if (event.locationName.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    event.locationName,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (event.googleMapsUrl != null &&
                                    event.googleMapsUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  PrimaryButton(
                                    text: 'عرض الموقع على الخريطة',
                                    icon: Icons.map_outlined,
                                    height: 48,
                                    isOutlined: true,
                                    onPressed: () =>
                                        _openGoogleMaps(event.googleMapsUrl!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
 
                          // Description
                          if (event.description.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.description_outlined,
                              title: 'حول الفعالية',
                              child: Text(
                                event.description,
                                style: AppTextStyles.bodyMd.copyWith(
                                  height: 1.6,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Creator Info
                          _buildDetailCard(
                            icon: Icons.person_outline,
                            title: 'منظم الفعالية',
                            child: InkWell(
                              onTap: () {
                                // Navigate to creator profile details
                                Navigator.of(context).pushNamed(
                                  AppRoutes.profile,
                                  arguments: event.creatorId,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          AppColors.surfaceContainerHigh,
                                      backgroundImage:
                                          event.creator.avatarUrl != null &&
                                              event
                                                  .creator
                                                  .avatarUrl!
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              event.creator.avatarUrl!,
                                            )
                                          : null,
                                      child:
                                          event.creator.avatarUrl == null ||
                                              event.creator.avatarUrl!.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 28,
                                              color: AppColors.outline,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.creator.fullName.isNotEmpty
                                                ? event.creator.fullName
                                                : '@${event.creator.username}',
                                            style: AppTextStyles.titleSm
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '@${event.creator.username}',
                                            style: AppTextStyles.bodySm
                                                .copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<EventDetailsCubit, EventDetailsState>(
        builder: (context, state) {
          if (state is EventDetailsLoaded) {
            final authState = context.read<AuthCubit>().state;
            final currentUserId =
                (authState is AuthSuccess) ? authState.user.id : '';
            final isOwnEvent = state.event.creatorId == currentUserId;

            if (isOwnEvent) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outline,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: PrimaryButton(
                  text: state.isSaved ? 'إزالة من المهتم بها' : 'إضافة إلى المهتم بها',
                  icon: state.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  isOutlined: state.isSaved,
                  onPressed: () {
                    if (currentUserId.isNotEmpty) {
                      context
                          .read<EventDetailsCubit>()
                          .toggleSave(currentUserId);
                    } else {
                      context.showSnackBar(
                        'يرجى تسجيل الدخول لحفظ الفعاليات',
                        isError: true,
                      );
                    }
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest, // Pure white
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Level 2 ambient shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.surfaceContainerLow),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTimeRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
