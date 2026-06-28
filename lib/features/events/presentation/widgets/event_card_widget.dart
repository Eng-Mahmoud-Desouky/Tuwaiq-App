import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';

class EventCardWidget extends StatelessWidget {
  final EventEntity event;
  final VoidCallback? onTap;

  const EventCardWidget({super.key, required this.event, this.onTap});

  String _formatDateTime(DateTime dateTime) {
    // Basic formatting in Arabic for presentation (e.g. "20 يونيو 2026 - 18:30")
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
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month | $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest, // Pure white
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.06,
              ), // Level 2: 0px 8px 24px rgba(0, 0, 0, 0.06)
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            AspectRatio(
              aspectRatio: 16 / 9,
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
                                size: 48,
                                color: AppColors.outline,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(
                            Icons.event_available_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                  // Category Chip on top right (RTL: top right means alignment top-left on screen or top-right. Let's place it at top-right for visual balance)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(
                          0.1,
                        ), // 10% opacity Electric Blue
                        borderRadius: BorderRadius.circular(999), // pill-shaped
                      ),
                      child: Text(
                        event.category,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary, // Saturated primary
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // RTL orientation
                children: [
                  // Title
                  Text(
                    event.title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatDateTime(event.startDate),
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          event.city.isNotEmpty
                              ? '${event.city}، ${event.locationName}'
                              : event.locationName,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    color: AppColors.surfaceContainerLow,
                  ),
                  const SizedBox(height: 12),
                  // Creator profile row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status or region tag
                      if (event.region.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.region,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      // Creator avatar + name
                      Row(
                        children: [
                          Text(
                            event.creator.fullName.isNotEmpty
                                ? event.creator.fullName
                                : '@${event.creator.username}',
                            style: AppTextStyles.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.surfaceContainerLow,
                            backgroundImage:
                                event.creator.avatarUrl != null &&
                                    event.creator.avatarUrl!.isNotEmpty
                                ? NetworkImage(event.creator.avatarUrl!)
                                : null,
                            child:
                                event.creator.avatarUrl == null ||
                                    event.creator.avatarUrl!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.outline,
                                  )
                                : null,
                          ),
                        ],
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
