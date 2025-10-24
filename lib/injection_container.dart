import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:my_login_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_login_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_login_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_login_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_login_app/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}