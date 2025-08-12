import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/login_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/reset_password_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/signup_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signUpUseCase.call(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        emit(AuthSuccess('Account created'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await signInUseCase.call(email: event.email, password: event.password);
        emit(AuthSuccess('Login successful'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendResetEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await resetPasswordUseCase.sendResetEmail(email: event.email);
        emit(AuthSuccess('Password reset email sent'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<VerifyResetCodeEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final email = await resetPasswordUseCase.verifyCode(code: event.code);
        emit(VerifyCodeLoaded(email));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ConfirmResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await resetPasswordUseCase.confirmReset(
          code: event.code,
          newPassword: event.newPassword,
        );
        emit(AuthSuccess('Password changed successfully'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
