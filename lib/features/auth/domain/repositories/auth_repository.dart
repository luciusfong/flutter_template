import 'package:my_login_app/core/errors/failures.dart';
import 'package:my_login_app/features/auth/domain/entities/user.dart';
import 'package:my_login_app/core/utils/validators.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
}