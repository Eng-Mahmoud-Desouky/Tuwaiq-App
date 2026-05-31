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

// Presentation
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
  final authRemoteDataSource = AuthRemoteDataSourceImpl(supabaseClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  final signUpUseCase = SignUpUseCase(authRepository);
  final signInUseCase = SignInUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final updatePasswordUseCase = UpdatePasswordUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final saveUserInterestsUseCase = SaveUserInterestsUseCase(authRepository);

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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuwaiq App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Handle startup routing dynamically based on initial state
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
          // If interests are already selected, go to Home, otherwise go to interests selection
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
