import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Core
import 'shared/theme/app_theme.dart';

// Data
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Domain
import 'core/router/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/save_user_interests_usecase.dart';

// Profile Feature Imports
// Domain
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/get_profile_social_stats_usecase.dart';

// Events Feature Imports
// Domain
import 'features/events/domain/usecases/create_event_usecase.dart';
import 'features/events/domain/usecases/get_event_usecase.dart';
import 'features/events/domain/usecases/get_all_events_usecase.dart';
import 'features/events/domain/usecases/save_event_usecase.dart';
import 'features/events/domain/usecases/unsave_event_usecase.dart';
import 'features/events/domain/usecases/is_event_saved_usecase.dart';
import 'features/events/domain/usecases/get_events_by_user_usecase.dart';
import 'features/events/domain/usecases/get_saved_events_usecase.dart';
// Data
import 'features/events/data/datasources/event_remote_datasource.dart';
import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/profile/domain/usecases/follow_user_usecase.dart';
import 'features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'features/profile/domain/usecases/get_followers_usecase.dart';
import 'features/profile/domain/usecases/get_following_usecase.dart';

// Data
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';

// Posts Feature Imports
import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/usecases/create_post_usecase.dart';
import 'features/posts/domain/usecases/get_posts_feed_usecase.dart';
import 'features/posts/domain/usecases/toggle_like_usecase.dart';
import 'features/posts/domain/usecases/get_comments_usecase.dart';
import 'features/posts/domain/usecases/add_comment_usecase.dart';
import 'features/posts/domain/usecases/delete_post_usecase.dart';
import 'features/posts/domain/usecases/delete_comment_usecase.dart';
import 'features/posts/domain/usecases/update_comment_usecase.dart';
import 'features/posts/presentation/cubits/post_feed/post_feed_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Instantiation & Dependency Injection
  final supabaseClient = Supabase.instance.client;

  // Auth
  final authRemoteDataSource = AuthRemoteDataSourceImpl(supabaseClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final signUpUseCase = SignUpUseCase(authRepository);
  final signInUseCase = SignInUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final updatePasswordUseCase = UpdatePasswordUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final saveUserInterestsUseCase = SaveUserInterestsUseCase(authRepository);

  // Profile
  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(supabaseClient);
  final profileRepository = ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
  );

  final getProfileUseCase = GetProfileUseCase(profileRepository);
  final updateProfileUseCase = UpdateProfileUseCase(profileRepository);
  final getProfileSocialStatsUseCase = GetProfileSocialStatsUseCase(
    profileRepository,
  );
  final followUserUseCase = FollowUserUseCase(profileRepository);
  final unfollowUserUseCase = UnfollowUserUseCase(profileRepository);
  final getFollowersUseCase = GetFollowersUseCase(profileRepository);
  final getFollowingUseCase = GetFollowingUseCase(profileRepository);

  // Events
  final eventRemoteDataSource = EventRemoteDataSourceImpl(supabaseClient);
  final eventRepository = EventRepositoryImpl(
    remoteDataSource: eventRemoteDataSource,
  );
  final createEventUseCase = CreateEventUseCase(eventRepository);
  final getEventUseCase = GetEventUseCase(eventRepository);
  final getAllEventsUseCase = GetAllEventsUseCase(eventRepository);
  final saveEventUseCase = SaveEventUseCase(eventRepository);
  final unsaveEventUseCase = UnsaveEventUseCase(eventRepository);
  final isEventSavedUseCase = IsEventSavedUseCase(eventRepository);
  final getEventsByUserUseCase = GetEventsByUserUseCase(eventRepository);
  final getSavedEventsUseCase = GetSavedEventsUseCase(eventRepository);

  // Posts
  final postRemoteDataSource = PostRemoteDataSourceImpl(supabaseClient);
  final postRepository = PostRepositoryImpl(remoteDataSource: postRemoteDataSource);
  final createPostUseCase = CreatePostUseCase(postRepository);
  final getPostsFeedUseCase = GetPostsFeedUseCase(postRepository);
  final toggleLikeUseCase = ToggleLikeUseCase(postRepository);
  final getCommentsUseCase = GetCommentsUseCase(postRepository);
  final addCommentUseCase = AddCommentUseCase(postRepository);
  final deleteCommentUseCase = DeleteCommentUseCase(postRepository);
  final updateCommentUseCase = UpdateCommentUseCase(postRepository);
  final deletePostUseCase = DeletePostUseCase(postRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            signUpUseCase: signUpUseCase,
            signInUseCase: signInUseCase,
            signOutUseCase: signOutUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            updatePasswordUseCase: updatePasswordUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            saveUserInterestsUseCase: saveUserInterestsUseCase,
          )..checkCurrentUser(),
        ),
        BlocProvider<PostFeedCubit>(
          create: (context) => PostFeedCubit(
            getPostsFeedUseCase: getPostsFeedUseCase,
            toggleLikeUseCase: toggleLikeUseCase,
            deletePostUseCase: deletePostUseCase,
            getAllEventsUseCase: getAllEventsUseCase,
          )..loadPosts(),
        ),
      ],
      child: MyApp(
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        getProfileSocialStatsUseCase: getProfileSocialStatsUseCase,
        followUserUseCase: followUserUseCase,
        unfollowUserUseCase: unfollowUserUseCase,
        getFollowersUseCase: getFollowersUseCase,
        getFollowingUseCase: getFollowingUseCase,
        createEventUseCase: createEventUseCase,
        getEventUseCase: getEventUseCase,
        getAllEventsUseCase: getAllEventsUseCase,
        saveEventUseCase: saveEventUseCase,
        unsaveEventUseCase: unsaveEventUseCase,
        isEventSavedUseCase: isEventSavedUseCase,
        getEventsByUserUseCase: getEventsByUserUseCase,
        getSavedEventsUseCase: getSavedEventsUseCase,
        createPostUseCase: createPostUseCase,
        getPostsFeedUseCase: getPostsFeedUseCase,
        toggleLikeUseCase: toggleLikeUseCase,
        getCommentsUseCase: getCommentsUseCase,
        addCommentUseCase: addCommentUseCase,
        deleteCommentUseCase: deleteCommentUseCase,
        updateCommentUseCase: updateCommentUseCase,
        deletePostUseCase: deletePostUseCase,
        updatePasswordUseCase: updatePasswordUseCase,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetProfileSocialStatsUseCase getProfileSocialStatsUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;
  final GetFollowersUseCase getFollowersUseCase;
  final GetFollowingUseCase getFollowingUseCase;
  final CreateEventUseCase createEventUseCase;
  final GetEventUseCase getEventUseCase;
  final GetAllEventsUseCase getAllEventsUseCase;
  final SaveEventUseCase saveEventUseCase;
  final UnsaveEventUseCase unsaveEventUseCase;
  final IsEventSavedUseCase isEventSavedUseCase;
  final GetEventsByUserUseCase getEventsByUserUseCase;
  final GetSavedEventsUseCase getSavedEventsUseCase;
  final CreatePostUseCase createPostUseCase;
  final GetPostsFeedUseCase getPostsFeedUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeletePostUseCase deletePostUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;

  const MyApp({
    super.key,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getProfileSocialStatsUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    required this.getFollowersUseCase,
    required this.getFollowingUseCase,
    required this.createEventUseCase,
    required this.getEventUseCase,
    required this.getAllEventsUseCase,
    required this.saveEventUseCase,
    required this.unsaveEventUseCase,
    required this.isEventSavedUseCase,
    required this.getEventsByUserUseCase,
    required this.getSavedEventsUseCase,
    required this.createPostUseCase,
    required this.getPostsFeedUseCase,
    required this.toggleLikeUseCase,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
    required this.updateCommentUseCase,
    required this.deletePostUseCase,
    required this.updatePasswordUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router(
      context.read<AuthCubit>(),
      getProfileUseCase: getProfileUseCase,
      updateProfileUseCase: updateProfileUseCase,
      getProfileSocialStatsUseCase: getProfileSocialStatsUseCase,
      followUserUseCase: followUserUseCase,
      unfollowUserUseCase: unfollowUserUseCase,
      getFollowersUseCase: getFollowersUseCase,
      getFollowingUseCase: getFollowingUseCase,
      createEventUseCase: createEventUseCase,
      getEventUseCase: getEventUseCase,
      saveEventUseCase: saveEventUseCase,
      unsaveEventUseCase: unsaveEventUseCase,
      isEventSavedUseCase: isEventSavedUseCase,
      getEventsByUserUseCase: getEventsByUserUseCase,
      getSavedEventsUseCase: getSavedEventsUseCase,
      createPostUseCase: createPostUseCase,
      getPostsFeedUseCase: getPostsFeedUseCase,
      toggleLikeUseCase: toggleLikeUseCase,
      getCommentsUseCase: getCommentsUseCase,
      addCommentUseCase: addCommentUseCase,
      deleteCommentUseCase: deleteCommentUseCase,
      updateCommentUseCase: updateCommentUseCase,
      deletePostUseCase: deletePostUseCase,
      updatePasswordUseCase: updatePasswordUseCase,
    );

    return MaterialApp.router(
      title: 'Tuwaiq App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'AE'), Locale('en', 'US')],
      locale: const Locale('ar'),
    );
  }
}
