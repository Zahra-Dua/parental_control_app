import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class SendResetEmailEvent extends AuthEvent {
  final String email;
  SendResetEmailEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class VerifyResetCodeEvent extends AuthEvent {
  final String code;
  VerifyResetCodeEvent(this.code);
  @override
  List<Object?> get props => [code];
}

class ConfirmResetPasswordEvent extends AuthEvent {
  final String code;
  final String newPassword;
  ConfirmResetPasswordEvent({required this.code, required this.newPassword});
  @override
  List<Object?> get props => [code];
}
