import 'package:http/http.dart' as http;
import 'package:my_login_app/core/constants/api_constants.dart';
import 'package:my_login_app/core/errors/failures.dart';
import 'dart:convert';

import 'package:my_login_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      ).timeout(ApiConstants.timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw ServerFailure('Login failed');
      }
    } catch (e) {
      throw NetworkFailure('Network error: $e');
    }
  }
}