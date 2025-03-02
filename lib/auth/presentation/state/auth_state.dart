part of '../bloc/auth_bloc.dart';

class AuthState extends Equatable {
  final bool authenticated;
  final String? userId;
  final String? errorMessage;
  final bool isInitializing;
  final UserRole role;

  const AuthState({
    this.authenticated = false,
    this.userId,
    this.isInitializing = false,
    this.errorMessage,
    this.role = UserRole.none,
  });

  AuthState copyWith({
    bool? authenticated,
    String? userId,
    String? errorMessage,
    bool? isInitializing,
    UserRole? role,
  }) {
    return AuthState(
      authenticated: authenticated ?? this.authenticated,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitializing: isInitializing ?? this.isInitializing,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
    authenticated,
    userId,
    isInitializing,
    errorMessage,
    role,
  ];
}
