import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/interests_screen.dart';
import '../../features/dms/presentation/screens/dms_placeholder_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/auth/presentation/cubit/update_password_cubit.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/profile/domain/usecases/follow_user_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_social_stats_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/unfollow_user_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_followers_usecase.dart';
import '../../features/profile/domain/usecases/get_following_usecase.dart';
import '../../features/profile/presentation/cubit/connections_cubit.dart';
import '../../features/profile/presentation/cubit/profile_info_cubit.dart';
import '../../features/profile/presentation/cubit/profile_social_cubit.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/social_connections_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/cubit/explore_cubit.dart';
import '../../features/events/presentation/screens/create_event.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import '../../core/services/notification_service.dart';
import '../../features/events/domain/entities/event_entity.dart';
import '../../features/events/domain/usecases/get_all_events_usecase.dart';
import '../../features/events/domain/usecases/create_event_usecase.dart';
import '../../features/events/domain/usecases/get_event_usecase.dart';
import '../../features/events/domain/usecases/save_event_usecase.dart';
import '../../features/events/domain/usecases/unsave_event_usecase.dart';
import '../../features/events/domain/usecases/is_event_saved_usecase.dart';
import '../../features/events/domain/usecases/get_events_by_user_usecase.dart';
import '../../features/events/domain/usecases/get_saved_events_usecase.dart';
import '../../features/profile/presentation/cubit/profile_posts_cubit.dart';
import '../../features/profile/presentation/cubit/profile_likes_cubit.dart';
import '../../features/posts/domain/usecases/get_liked_posts_usecase.dart';
import '../../features/posts/domain/usecases/search_posts_usecase.dart';
import '../../features/profile/domain/usecases/search_profiles_usecase.dart';
import '../../features/profile/presentation/cubit/profile_events_cubit.dart';
import '../../features/profile/presentation/cubit/profile_saved_events_cubit.dart';
import '../../features/events/presentation/cubit/create_event_cubit.dart';
import '../../features/posts/domain/entities/post_entity.dart';
import '../../features/posts/domain/usecases/create_post_usecase.dart';
import '../../features/posts/domain/usecases/get_posts_feed_usecase.dart';
import '../../features/posts/domain/usecases/toggle_like_usecase.dart';
import '../../features/posts/domain/usecases/get_comments_usecase.dart';
import '../../features/posts/domain/usecases/add_comment_usecase.dart';
import '../../features/posts/domain/usecases/delete_post_usecase.dart';
import '../../features/posts/domain/usecases/delete_comment_usecase.dart';
import '../../features/posts/domain/usecases/update_comment_usecase.dart';
import '../../features/posts/presentation/cubits/create_post/create_post_cubit.dart';
import '../../features/posts/presentation/cubits/post_comments/post_comments_cubit.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../features/posts/presentation/screens/post_details_screen.dart';

class AppRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  AppRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(
    AuthCubit authCubit, {
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetProfileSocialStatsUseCase getProfileSocialStatsUseCase,
    required FollowUserUseCase followUserUseCase,
    required UnfollowUserUseCase unfollowUserUseCase,
    required GetFollowersUseCase getFollowersUseCase,
    required GetFollowingUseCase getFollowingUseCase,
    required CreateEventUseCase createEventUseCase,
    required GetEventUseCase getEventUseCase,
    required GetAllEventsUseCase getAllEventsUseCase,
    required SaveEventUseCase saveEventUseCase,
    required UnsaveEventUseCase unsaveEventUseCase,
    required IsEventSavedUseCase isEventSavedUseCase,
    required GetEventsByUserUseCase getEventsByUserUseCase,
    required GetSavedEventsUseCase getSavedEventsUseCase,
    required CreatePostUseCase createPostUseCase,
    required GetPostsFeedUseCase getPostsFeedUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required GetCommentsUseCase getCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required UpdateCommentUseCase updateCommentUseCase,
    required DeletePostUseCase deletePostUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
    required SearchProfilesUseCase searchProfilesUseCase,
    required GetLikedPostsUseCase getLikedPostsUseCase,
    required SearchPostsUseCase searchPostsUseCase,
  }) {
    final routerInstance = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.signIn,
      refreshListenable: AppRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuthScreen =
            state.matchedLocation.startsWith('/sign') ||
            state.matchedLocation.startsWith('/forgot') ||
            state.matchedLocation.startsWith('/update') ||
            state.matchedLocation.startsWith('/reset-callback');

        if (authState is AuthLoading) {
          // Wait for loading to finish, no redirect yet
          return null;
        }

        if (authState is AuthPasswordRecovery) {
          if (state.matchedLocation == AppRoutes.updatePassword) {
            return null;
          }
          return AppRoutes.updatePassword;
        }

        if (authState is AuthInitial || authState is AuthError) {
          return isAuthScreen ? null : AppRoutes.signIn;
        }

        if (authState is AuthSuccess) {
          // Bypass redirect to home during password recovery flow
          final isResetFlow = state.matchedLocation == AppRoutes.updatePassword ||
                              state.matchedLocation == '/reset-callback';
          if (isResetFlow) {
            return null;
          }

          if (authState.user.interests.length < 3 &&
              state.matchedLocation != AppRoutes.interests) {
            return AppRoutes.interests;
          }
          if (authState.user.interests.length >= 3 && isAuthScreen) {
            return AppRoutes.home;
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.updatePassword,
          builder: (context, state) => BlocProvider(
            create: (context) => UpdatePasswordCubit(
              updatePasswordUseCase: updatePasswordUseCase,
            ),
            child: const UpdatePasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/reset-callback',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.dms,
          builder: (context, state) => const DmsPlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.interests,
          builder: (context, state) => const InterestsScreen(),
        ),
        GoRoute(
          path: AppRoutes.eventDetails,
          redirect: (context, state) => AppRoutes.home,
        ),
        GoRoute(
          path: AppRoutes.createPost,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (context) => CreatePostCubit(
              createPostUseCase: createPostUseCase,
            ),
            child: const CreatePostScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.postDetails,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final postId = state.pathParameters['id']!;
            final post = state.extra as PostEntity?;
            return BlocProvider(
              create: (context) => PostCommentsCubit(
                getCommentsUseCase: getCommentsUseCase,
                addCommentUseCase: addCommentUseCase,
                deleteCommentUseCase: deleteCommentUseCase,
                updateCommentUseCase: updateCommentUseCase,
              ),
              child: PostDetailsScreen(
                eventId: postId,
                initialPost: post,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.editEvent,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final event = state.extra as EventEntity?;
            return BlocProvider(
              create: (context) => CreateEventCubit(
                createEventUseCase: createEventUseCase,
              ),
              child: CreateEventScreen(eventToEdit: event),
            );
          },
        ),

        // Main Navigation (StatefulShellRoute)
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Explore/Search Branch (1)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.explore,
                  builder: (context, state) => BlocProvider(
                    create: (context) => ExploreCubit(
                      searchPostsUseCase: searchPostsUseCase,
                      searchProfilesUseCase: searchProfilesUseCase,
                    ),
                    child: const ExploreScreen(),
                  ),
                ),
              ],
            ),
            // Alerts Branch (2)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.alerts,
                  builder: (context, state) {
                    final authState = context.read<AuthCubit>().state;
                    final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
                    return BlocProvider(
                      create: (context) => NotificationsCubit(
                        getNotificationsUseCase: getNotificationsUseCase,
                        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
                        userId: currentUserId,
                      )..loadNotifications(),
                      child: const NotificationsScreen(),
                    );
                  },
                ),
              ],
            ),
            // DMs Branch (3)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.dms,
                  builder: (context, state) => const DmsPlaceholderScreen(),
                ),
              ],
            ),
            // Profile Branch (4)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) {
                    final targetUserId = state.extra as String?;
                    final authState = context.read<AuthCubit>().state;
                    final currentUserId = (authState is AuthSuccess)
                        ? authState.user.id
                        : '';
                    final finalUserId = targetUserId ?? currentUserId;

                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => ProfileInfoCubit(
                            getProfileUseCase: getProfileUseCase,
                            updateProfileUseCase: updateProfileUseCase,
                          )..loadProfile(finalUserId),
                        ),
                        BlocProvider(
                          create: (context) => ProfileSocialCubit(
                            getProfileSocialStatsUseCase:
                                getProfileSocialStatsUseCase,
                            followUserUseCase: followUserUseCase,
                            unfollowUserUseCase: unfollowUserUseCase,
                          )..loadSocialStats(finalUserId, currentUserId),
                        ),
                        BlocProvider(
                          create: (context) => ProfilePostsCubit(
                            getPostsFeedUseCase: getPostsFeedUseCase,
                            userId: finalUserId,
                          )..loadPosts(),
                        ),
                        BlocProvider(
                          create: (context) => ProfileLikesCubit(
                            getLikedPostsUseCase: getLikedPostsUseCase,
                            userId: finalUserId,
                          )..loadLikes(),
                        ),
                      ],
                      child: ProfileScreen(userId: finalUserId),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: AppRoutes.editProfile,
                      builder: (context, state) {
                        final userProfile = state.extra as UserProfile;
                        return BlocProvider(
                          create: (context) => ProfileInfoCubit(
                            getProfileUseCase: getProfileUseCase,
                            updateProfileUseCase: updateProfileUseCase,
                          )..setProfile(userProfile),
                          child: const EditProfileScreen(),
                        );
                      },
                    ),
                    GoRoute(
                      path: AppRoutes.connections,
                      builder: (context, state) {
                        final args = state.extra as Map<String, dynamic>;
                        final targetUserId = args['userId'] as String;
                        final targetUserName = args['userName'] as String;
                        final initialIndex = args['initialIndex'] as int? ?? 0;

                        final authState = context.read<AuthCubit>().state;
                        final currentUserId = (authState is AuthSuccess)
                            ? authState.user.id
                            : '';

                        return BlocProvider(
                          create: (context) =>
                              ConnectionsCubit(
                                getFollowersUseCase: getFollowersUseCase,
                                getFollowingUseCase: getFollowingUseCase,
                                followUserUseCase: followUserUseCase,
                                unfollowUserUseCase: unfollowUserUseCase,
                              )..loadConnections(
                                targetUserId: targetUserId,
                                currentUserId: currentUserId,
                              ),
                          child: SocialConnectionsScreen(
                            targetUserId: targetUserId,
                            targetUserName: targetUserName,
                            initialIndex: initialIndex,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    // Setup FCM / Local Notifications Deep Linking stream listener
    NotificationService().selectNotificationStream.listen((data) {
      final type = data['type'];
      final targetId = data['target_id'];
      if (targetId != null && targetId.isNotEmpty) {
        if (type == 'comment' || type == 'like') {
          routerInstance.push('/posts/$targetId');
        } else if (type == 'event_update') {
          routerInstance.push('/events/$targetId');
        }
      }
    });

    return routerInstance;
  }
}
