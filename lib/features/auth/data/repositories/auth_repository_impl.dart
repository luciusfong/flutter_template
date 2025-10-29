import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_template/core/errors/failures.dart';
import 'package:flutter_template/core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final DioClient dioClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.dioClient,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final response = await remoteDataSource.login({
        'username': username,
        'password': password,
      });

      if (response.response.statusCode == 200) {
        final userModel = response.data;
        
        if (userModel.accessToken != null) {
          await dioClient.saveToken(
            userModel.accessToken!,
          );
        }

        return Right(userModel.toEntity());
      } else {
        return Left(ServerFailure('Login failed'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Server error';
        
        if (statusCode == 401) {
          return ServerFailure('Invalid credentials');
        } else if (statusCode == 400) {
          return ServerFailure(message);
        }
        return ServerFailure(message);
      
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection');
      
      default:
        return NetworkFailure('Network error');
    }
  }
}