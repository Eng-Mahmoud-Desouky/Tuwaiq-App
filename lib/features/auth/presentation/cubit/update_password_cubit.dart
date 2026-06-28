import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_password_usecase.dart';
import 'update_password_state.dart';

class UpdatePasswordCubit extends Cubit<UpdatePasswordState> {
  final UpdatePasswordUseCase updatePasswordUseCase;

  UpdatePasswordCubit({
    required this.updatePasswordUseCase,
  }) : super(const UpdatePasswordInitial());

  Future<void> updatePassword({required String newPassword}) async {
    emit(const UpdatePasswordLoading());
    try {
      await updatePasswordUseCase(newPassword: newPassword);
      emit(const UpdatePasswordSuccess());
    } catch (e) {
      emit(
        UpdatePasswordError(
          e
              .toString()
              .replaceAll('Failure:', '')
              .replaceAll('AuthFailure:', '')
              .replaceAll('Exception:', '')
              .trim(),
        ),
      );
    }
  }
}
