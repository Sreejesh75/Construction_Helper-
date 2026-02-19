import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_api_service.dart';
import '../../../core/utils/local_storage.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApiService _authApiService;

  LoginBloc(this._authApiService) : super(const LoginState()) {
    debugPrint("LoginBloc: Initialized");
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, errorMessage: null));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // ✅ Basic validation
    if (!state.email.contains("@")) {
      emit(state.copyWith(errorMessage: "Please enter a valid email"));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // ✅ REAL API CALL
      print("LoginBloc: dispatching login request for ${state.email}");
      final result = await _authApiService.loginWithEmail(
        name: state.email.split('@').first,
        email: state.email,
      );

      final userId = result['userId'];
      final userName = result['name'];
      final isNewUser = result['isNewUser'] as bool;

      // ✅ Persist login
      await LocalStorage.saveUserId(userId);

      emit(
        state.copyWith(
          isLoading: false,
          userId: userId, // ✅ success signal
          userName: userName,
          isNewUser: isNewUser,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await _authApiService.loginWithGoogle();

      final userId = result['userId'];
      final userName = result['name'];
      final isNewUser = result['isNewUser'] as bool;
      final email = result['email'];

      // ✅ Persist login
      await LocalStorage.saveUserId(userId);

      emit(
        state.copyWith(
          isLoading: false,
          userId: userId,
          userName: userName,
          isNewUser: isNewUser,
          email: email,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
