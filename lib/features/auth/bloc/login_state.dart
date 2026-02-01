import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final String? userId; // ✅ NEW
  final String? userName;
  final bool isNewUser;

  const LoginState({
    this.email = '',
    this.isLoading = false,
    this.errorMessage,
    this.userId,
    this.userName,
    this.isNewUser = false,
  });

  LoginState copyWith({
    String? email,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? userName,
    bool? isNewUser,
  }) {
    return LoginState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
    email,
    isLoading,
    errorMessage,
    userId,
    userName,
    isNewUser,
  ];
}
