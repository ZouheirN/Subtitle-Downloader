part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

// Sign Up
class SignUpInitialEvent extends AuthenticationEvent {
  final String email;
  final String password;
  final String username;

  SignUpInitialEvent(this.email, this.password, this.username);
}

// Sign In
class SignInInitialEvent extends AuthenticationEvent {
  final String email;
  final String password;

  SignInInitialEvent(this.email, this.password);
}

// Sign Out
class SignOutInitialEvent extends AuthenticationEvent {}

// Password Reset
class PasswordResetInitialEvent extends AuthenticationEvent {
  final String email;

  PasswordResetInitialEvent(this.email);
}