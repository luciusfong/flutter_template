import 'package:get_it/get_it.dart';
import 'package:flutter_template/core/network/dio_client.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_template/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🔹 BLoC
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // 🔹 Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));

  // 🔹 Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      dioClient: sl(), // ✅ added this
    ),
  );

  // 🔹 Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      sl<DioClient>().dio, // pass the actual Dio instance
      baseUrl: dotenv.env['BASE_URL'] ?? '', // ✅ loaded from .env
    ),
  );

  // 🔹 Core / External
  sl.registerLazySingleton(() => DioClient()); // ✅ added this
}