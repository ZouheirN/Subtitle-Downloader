part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

abstract class AuthenticationActionState extends AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

// Sign Up
class SignUpLoadingState extends AuthenticationState {}

class SignUpErrorState extends AuthenticationState {
  final String errorMessage;

  SignUpErrorState(this.errorMessage);
}

class SignUpSuccessfulState extends AuthenticationState {
  final User user;

  SignUpSuccessfulState(this.user);
}

// Sign In
class SignInLoadingState extends AuthenticationState {}

class SignInErrorState extends AuthenticationState {
  final String errorMessage;

  SignInErrorState(this.errorMessage);
}

class SignInSuccessfulState extends AuthenticationState {
  final User user;

  SignInSuccessfulState(this.user);
}

// Sign Out
class SignOutLoadingState extends AuthenticationState {}

class SignOutErrorState extends AuthenticationState {
  final String errorMessage;

  SignOutErrorState(this.errorMessage);
}

class SignOutSuccessfulState extends AuthenticationState {}