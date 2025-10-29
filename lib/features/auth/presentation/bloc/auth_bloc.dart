import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:dartz/dartz.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.username, event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}