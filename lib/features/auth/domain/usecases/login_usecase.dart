import 'package:my_login_app/core/errors/failures.dart';
import 'package:my_login_app/features/auth/domain/entities/user.dart';
import 'package:my_login_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_login_app/core/utils/validators.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, User>> call(String username, String password) async {
    return await repository.login(username, password);
  }
}