import 'package:flutter_template/core/errors/failures.dart';
import 'package:flutter_template/features/auth/domain/entities/user.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, User>> call(String username, String password) async {
    return await repository.login(username, password);
  }
}