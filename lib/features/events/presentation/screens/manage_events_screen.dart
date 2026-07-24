import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../profile/presentation/cubit/profile_events_cubit.dart';
import '../../../profile/presentation/cubit/profile_saved_events_cubit.dart';
import '../widgets/event_card_widget.dart';
import '../../../../core/constants/app_routes.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  int _activeTab = 0; // 0: فعالياتي, 1: المهتم بها

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ProfileEventsCubit>().loadEvents();
      context.read<ProfileSavedEventsCubit>().loadSavedEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarAvatar(),
        title: Image.asset(
          'assets/images/logo.png',
          height: 42,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () {
          context.go(AppRoutes.create);
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Custom Sliding Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'فعالياتي',
                            style: AppTextStyles.labelLg.copyWith(
                              color: _activeTab == 0 ? AppColors.onPrimary : AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'المهتم بها',
                            style: AppTextStyles.labelLg.copyWith(
                              color: _activeTab == 1 ? AppColors.onPrimary : AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab Content
            Expanded(
              child: _activeTab == 0
                  ? _buildMyEventsList()
                  : _buildSavedEventsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEventsList() {
    return BlocBuilder<ProfileEventsCubit, ProfileEventsState>(
      builder: (context, state) {
        if (state is ProfileEventsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is ProfileEventsLoaded) {
          final events = state.events;
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'لم تقم بإنشاء أي فعاليات بعد.',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      EventCardWidget(
                        event: event,
                        onTap: () async {
                          await context.push('/events/${event.id}', extra: event);
                          _refreshData();
                        },
                      ),
                      const Divider(height: 1, color: AppColors.outline),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await context.push(AppRoutes.editEvent, extra: event);
                                _refreshData();
                              },
                              icon: const Icon(Icons.edit_note, size: 18, color: AppColors.primary),
                              label: const Text(
                                'تعديل الفعالية',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is ProfileEventsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSavedEventsList() {
    return BlocBuilder<ProfileSavedEventsCubit, ProfileSavedEventsState>(
      builder: (context, state) {
        if (state is ProfileSavedEventsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is ProfileSavedEventsLoaded) {
          final events = state.events;
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد فعاليات محفوظة حالياً.',
                style: TextStyle(color: AppColors.secondary, fontSize: 14),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: EventCardWidget(
                  event: event,
                  onTap: () async {
                    await context.push('/events/${event.id}', extra: event);
                    _refreshData();
                  },
                ),
              );
            },
          );
        } else if (state is ProfileSavedEventsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
