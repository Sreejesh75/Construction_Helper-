import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_api_service.dart';
import '../../../core/utils/local_storage.dart';
import 'login_event.dart';
import 'login_state.dart';

import '../../../core/services/notification_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApiService _authApiService;

  // Security: RFC 5322 compliant regex pattern for strict email validation
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  LoginBloc(this._authApiService) : super(const LoginState()) {
    debugPrint("LoginBloc: Initialized");
    on<AuthMethodChanged>(_onAuthMethodChanged);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPhoneChanged>(_onPhoneChanged);
    on<LoginOtpChanged>(_onOtpChanged);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetOtpStateRequested>(_onResetOtpStateRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  void _onAuthMethodChanged(AuthMethodChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      authMethod: event.method,
      errorMessage: null,
      successMessage: null,
    ));
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email.trim(), errorMessage: null));
  }

  void _onPhoneChanged(LoginPhoneChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(phone: event.phone.trim(), errorMessage: null));
  }

  void _onOtpChanged(LoginOtpChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(otp: event.otp.trim(), errorMessage: null));
  }

  void _onResetOtpStateRequested(
    ResetOtpStateRequested event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      isOtpSent: false,
      otp: '',
      devOtp: null,
      errorMessage: null,
      successMessage: null,
    ));
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<LoginState> emit,
  ) async {
    final cleanPhone = state.phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      emit(state.copyWith(
        errorMessage: "Please enter a valid 10-digit mobile number.",
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final result = await _authApiService.sendOtp(
        phone: cleanPhone,
        name: event.name,
      );

      final otpCode = result['otp'];

      // Show local push notification banner on device
      if (otpCode != null) {
        NotificationService.instance.showOtpNotification(
          otp: otpCode,
          phone: cleanPhone,
        );
      }

      emit(state.copyWith(
        isLoading: false,
        isOtpSent: true,
        devOtp: otpCode,
        successMessage: result['message'] ?? "OTP sent successfully",
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _sanitizeErrorMessage(e),
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<LoginState> emit,
  ) async {
    final cleanPhone = state.phone.replaceAll(RegExp(r'[^\d]'), '');
    final cleanOtp = state.otp.trim();

    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      emit(state.copyWith(
        errorMessage: "Mobile number is invalid. Please check and try again.",
      ));
      return;
    }

    if (cleanOtp.length != 4) {
      emit(state.copyWith(
        errorMessage: "Please enter a valid 4-digit OTP.",
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      final result = await _authApiService.verifyOtp(
        phone: cleanPhone,
        otp: cleanOtp,
      );

      final userId = result['userId'];
      final userName = result['name'];

      await LocalStorage.saveUserId(userId);

      emit(state.copyWith(
        isLoading: false,
        userId: userId,
        userName: userName,
        isNewUser: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _sanitizeErrorMessage(e),
      ));
    }
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

