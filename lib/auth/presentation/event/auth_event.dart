part of '../bloc/auth_bloc.dart';

enum UserRole {
  student,
  faculty,
  admin,
  none;

  bool get isStudent => this == student;
  bool get isFaculty => this == faculty;
  bool get isAdmin => this == admin;
  bool get isNone => this == none;
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAuthEvent extends AuthEvent {
  const InitializeAuthEvent();
}

class AuthenticatedEvent extends AuthEvent {
  final String userId;
  final UserRole role;

  const AuthenticatedEvent(this.userId, this.role);

  @override
  List<Object?> get props => [userId, role];
}

class UnauthenticatedEvent extends AuthEvent {
  const UnauthenticatedEvent();
}

class AuthSignOutEvent extends AuthEvent {
  const AuthSignOutEvent();
}

class AuthSignInEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String id;
  final String email;
  final String password;
  final UserRole role;

  const AuthSignUpEvent({
    required this.name,
    required this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, id, email, password, role];
}
