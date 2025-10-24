import 'package:flutter_template/core/errors/failures.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_template/features/auth/domain/entities/user.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final user = await remoteDataSource.login(username, password);
      return Either.right(user);
    } on ServerFailure catch (e) {
      return Either.left(e);
    } on NetworkFailure catch (e) {
      return Either.left(e);
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error'));
    }
  }
}