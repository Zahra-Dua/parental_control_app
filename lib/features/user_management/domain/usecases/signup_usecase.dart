import 'package:parental_control_app/features/user_management/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      name: name,
      userType: userType,
    );
  }
}
