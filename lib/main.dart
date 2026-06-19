import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'features/profile/domain/usecases/follow_user_usecase.dart';
import 'features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'features/profile/domain/usecases/get_followers_usecase.dart';
import 'features/profile/domain/usecases/get_following_usecase.dart';

// Data
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';


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
    final router = AppRouter.router(
      context.read<AuthCubit>(),
      getProfileUseCase: getProfileUseCase,
      updateProfileUseCase: updateProfileUseCase,
      getProfileSocialStatsUseCase: getProfileSocialStatsUseCase,
      followUserUseCase: followUserUseCase,
      unfollowUserUseCase: unfollowUserUseCase,
      getFollowersUseCase: getFollowersUseCase,
      getFollowingUseCase: getFollowingUseCase,
    );

    return MaterialApp.router(
      title: 'Tuwaiq App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
