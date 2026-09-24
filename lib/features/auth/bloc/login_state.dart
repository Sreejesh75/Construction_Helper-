import 'package:equatable/equatable.dart';
import 'login_event.dart';

class LoginState extends Equatable {
  final String email;
  final String phone;
  final String otp;
  final AuthMethod authMethod;
  final bool isOtpSent;
  final String? devOtp;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? userId;
  final String? userName;
  final bool isNewUser;

  const LoginState({
    this.email = '',
    this.phone = '',
    this.otp = '',
    this.authMethod = AuthMethod.email,
    this.isOtpSent = false,
    this.devOtp,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.userId,
    this.userName,
    this.isNewUser = false,
  });

  LoginState copyWith({
    String? email,
    String? phone,
    String? otp,
    AuthMethod? authMethod,
    bool? isOtpSent,
    String? devOtp,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? userId,
    String? userName,
    bool? isNewUser,
  }) {
    return LoginState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      authMethod: authMethod ?? this.authMethod,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      devOtp: devOtp ?? this.devOtp,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
        email,
        phone,
        otp,
        authMethod,
        isOtpSent,
        devOtp,
        isLoading,
        errorMessage,
        successMessage,
        userId,
        userName,
        isNewUser,
      ];
}
