import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String userType;

  SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });
  @override
  List<Object?> get props => [name, email, password, userType];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SendResetEmailEvent extends AuthEvent {
  final String email;
  SendResetEmailEvent({required this.email});
  @override
  List<Object?> get props => [email];
}

class VerifyResetCodeEvent extends AuthEvent {
  final String code;
  VerifyResetCodeEvent({required this.code});
  @override
  List<Object?> get props => [code];
}

class ConfirmResetEvent extends AuthEvent {
  final String code;
  final String newPassword;
  ConfirmResetEvent({required this.code, required this.newPassword});
  @override
  List<Object?> get props => [code, newPassword];
}
