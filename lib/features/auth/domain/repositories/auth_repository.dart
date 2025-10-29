import 'package:flutter_template/core/errors/failures.dart';
import 'package:flutter_template/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
}