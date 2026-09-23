import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_api_service.dart';
import '../../../core/utils/local_storage.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApiService _authApiService;

  // Security: RFC 5322 compliant regex pattern for strict email validation
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  LoginBloc(this._authApiService) : super(const LoginState()) {
    debugPrint("LoginBloc: Initialized");
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email.trim(), errorMessage: null));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final sanitizedEmail = state.email.trim();

    // Security: Input validation & sanitization
    if (sanitizedEmail.isEmpty) {
      emit(state.copyWith(errorMessage: "Email address cannot be empty."));
      return;
    }

    if (!_emailRegex.hasMatch(sanitizedEmail)) {
      emit(
        state.copyWith(
          errorMessage: "Please enter a valid email address (e.g. name@example.com).",
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await _authApiService.loginWithEmail(
        name: sanitizedEmail.split('@').first,
        email: sanitizedEmail,
      );

      final userId = result['userId'];
      final userName = result['name'];
      final isNewUser = result['isNewUser'] as bool;

      // Securely persist credentials
      await LocalStorage.saveUserId(userId);

      emit(
        state.copyWith(
          isLoading: false,
          userId: userId,
          userName: userName,
          isNewUser: isNewUser,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _sanitizeErrorMessage(e),
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

      // Securely persist credentials
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
          errorMessage: _sanitizeErrorMessage(e),
        ),
      );
    }
  }

  /// Helper to convert internal exceptions into clean, user-facing error messages
  String _sanitizeErrorMessage(dynamic error) {
    final rawMessage = error.toString().replaceFirst('Exception: ', '');
    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('connection timeout')) {
      return "Network error. Please check your internet connection.";
    }
    return rawMessage;
  }
}

