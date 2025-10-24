import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_login_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:my_login_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_login_app/features/auth/presentation/bloc/auth_state.dart';

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

    if (result.isRight()) {
      emit(AuthAuthenticated(result.right!));
    } else {
      emit(AuthError(result.left?.message ?? 'Login failed'));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}