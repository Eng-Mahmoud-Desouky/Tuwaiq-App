import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_info_state.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileInfoCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInfoInitial());

  Future<void> loadProfile(String userId) async {
    emit(ProfileInfoLoading());
    try {
      final profile = await getProfileUseCase(userId);
      emit(ProfileInfoLoaded(profile));
    } catch (e) {
      emit(
        ProfileInfoError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('ServerFailure:', '')
              .replaceAll('Exception:', '')
              .trim(),
        ),
      );
    }
  }

  void setProfile(UserProfile profile) {
    emit(ProfileInfoLoaded(profile));
  }

  Future<void> updateProfileDetails({
    required UserProfile profile,
    String? localAvatarPath,
  }) async {
    final currentState = state;
    UserProfile? fallbackProfile;
    if (currentState is ProfileInfoLoaded) {
      fallbackProfile = currentState.profile;
      emit(ProfileInfoUpdating(currentState.profile));
    } else {
      emit(ProfileInfoLoading());
    }

    try {
      final updatedProfile = await updateProfileUseCase(
        profile: profile,
        localAvatarPath: localAvatarPath,
      );
      emit(ProfileInfoUpdateSuccess(updatedProfile));
      emit(ProfileInfoLoaded(updatedProfile));
    } catch (e) {
      final errorMsg = e
          .toString()
          .replaceAll('Failure:', '')
          .replaceAll('ServerFailure:', '')
          .replaceAll('Exception:', '')
          .trim();
      emit(ProfileInfoError(errorMsg));
      if (fallbackProfile != null) {
        emit(ProfileInfoLoaded(fallbackProfile));
      }
    }
  }
}
