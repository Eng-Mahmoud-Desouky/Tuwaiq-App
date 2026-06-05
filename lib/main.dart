import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Core
import 'core/constants/app_routes.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/app_colors.dart';
import 'shared/screens/home_screen.dart';

// Data
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Domain
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/save_user_interests_usecase.dart';

// Profile Feature Imports
// Domain
import 'features/profile/domain/entities/user_profile.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/get_profile_social_stats_usecase.dart';
import 'features/profile/domain/usecases/follow_user_usecase.dart';
import 'features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'features/profile/domain/usecases/get_followers_usecase.dart';
import 'features/profile/domain/usecases/get_following_usecase.dart';

// Data
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';

// Presentation
import 'features/profile/presentation/cubit/profile_info_cubit.dart';
import 'features/profile/presentation/cubit/profile_social_cubit.dart';
import 'features/profile/presentation/cubit/connections_cubit.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/social_connections_screen.dart';

// Presentation (Auth)
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/update_password_screen.dart';
import 'features/auth/presentation/screens/email_confirmation_screen.dart';
import 'features/auth/presentation/screens/interests_screen.dart';

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
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  final signUpUseCase = SignUpUseCase(authRepository);
  final signInUseCase = SignInUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final updatePasswordUseCase = UpdatePasswordUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final saveUserInterestsUseCase = SaveUserInterestsUseCase(authRepository);

  // Profile
  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(supabaseClient);
  final profileRepository = ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);

  final getProfileUseCase = GetProfileUseCase(profileRepository);
  final updateProfileUseCase = UpdateProfileUseCase(profileRepository);
  final getProfileSocialStatsUseCase = GetProfileSocialStatsUseCase(profileRepository);
  final followUserUseCase = FollowUserUseCase(profileRepository);
  final unfollowUserUseCase = UnfollowUserUseCase(profileRepository);
  final getFollowersUseCase = GetFollowersUseCase(profileRepository);
  final getFollowingUseCase = GetFollowingUseCase(profileRepository);

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
      ],
      child: MyApp(
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        getProfileSocialStatsUseCase: getProfileSocialStatsUseCase,
        followUserUseCase: followUserUseCase,
        unfollowUserUseCase: unfollowUserUseCase,
        getFollowersUseCase: getFollowersUseCase,
        getFollowingUseCase: getFollowingUseCase,
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

  const MyApp({
    super.key,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getProfileSocialStatsUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    required this.getFollowersUseCase,
    required this.getFollowingUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuwaiq App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthStartupGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.signIn:
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case AppRoutes.signUp:
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case AppRoutes.forgotPassword:
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case AppRoutes.updatePassword:
            return MaterialPageRoute(builder: (_) => const UpdatePasswordScreen());
          case AppRoutes.emailConfirmation:
            final email = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => EmailConfirmationScreen(email: email),
            );
          case AppRoutes.interests:
            return MaterialPageRoute(builder: (_) => const InterestsScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.profile:
            final targetUserId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) {
                final authState = context.read<AuthCubit>().state;
                final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
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
                        getProfileSocialStatsUseCase: getProfileSocialStatsUseCase,
                        followUserUseCase: followUserUseCase,
                        unfollowUserUseCase: unfollowUserUseCase,
                      )..loadSocialStats(finalUserId, currentUserId),
                    ),
                  ],
                  child: ProfileScreen(userId: finalUserId),
                );
              },
            );
          case AppRoutes.editProfile:
            final userProfile = settings.arguments as UserProfile;
            return MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ProfileInfoCubit(
                  getProfileUseCase: getProfileUseCase,
                  updateProfileUseCase: updateProfileUseCase,
                )..setProfile(userProfile),
                child: const EditProfileScreen(),
              ),
            );
          case AppRoutes.connections:
            final args = settings.arguments as Map<String, dynamic>;
            final targetUserId = args['userId'] as String;
            final targetUserName = args['userName'] as String;
            final initialIndex = args['initialIndex'] as int? ?? 0;
            return MaterialPageRoute(
              builder: (context) {
                final authState = context.read<AuthCubit>().state;
                final currentUserId = (authState is AuthSuccess) ? authState.user.id : '';
                return BlocProvider(
                  create: (context) => ConnectionsCubit(
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
            );
          default:
            return MaterialPageRoute(builder: (_) => const SignInScreen());
        }
      },
    );
  }
}

class AuthStartupGate extends StatelessWidget {
  const AuthStartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.interests.length >= 3) {
            return const HomeScreen();
          } else {
            return const InterestsScreen();
          }
        } else if (state is AuthEmailNotConfirmed) {
          return EmailConfirmationScreen(email: state.email);
        } else if (state is AuthLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
