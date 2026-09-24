import 'package:equatable/equatable.dart';

enum AuthMethod { email, phone }

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when switching auth mode (Email vs Phone OTP)
class AuthMethodChanged extends LoginEvent {
  final AuthMethod method;

  const AuthMethodChanged(this.method);

  @override
  List<Object?> get props => [method];
}

/// Triggered when user types email
class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Triggered when user types phone number
class LoginPhoneChanged extends LoginEvent {
  final String phone;

  const LoginPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Triggered when user types OTP
class LoginOtpChanged extends LoginEvent {
  final String otp;

  const LoginOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// Triggered when user requests OTP
class SendOtpRequested extends LoginEvent {
  final String? name;

  const SendOtpRequested({this.name});

  @override
  List<Object?> get props => [name];
}

/// Triggered when user submits OTP for verification
class VerifyOtpRequested extends LoginEvent {}

/// Triggered to reset OTP input state (e.g. edit phone number)
class ResetOtpStateRequested extends LoginEvent {}

/// Triggered when user presses Sign In with Email
class LoginSubmitted extends LoginEvent {}

/// Triggered when user presses Google Sign In
class GoogleLoginRequested extends LoginEvent {}
