import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_template/core/constants/api_constants.dart';
import 'package:flutter_template/features/auth/data/models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) = _AuthRemoteDataSource;

  @POST(ApiConstants.login)
  Future<HttpResponse<UserModel>> login(
    @Body() Map<String, dynamic> credentials,
  );
}