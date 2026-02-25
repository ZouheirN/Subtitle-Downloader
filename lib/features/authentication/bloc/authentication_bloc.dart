import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/authentication/repos/auth_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<SignUpInitialEvent>(signUpInitialEvent);
    on<SignInInitialEvent>(signInInitialEvent);
    on<SignOutInitialEvent>(signOutInitialEvent);
    on<PasswordResetInitialEvent>(passwordResetInitialEvent);
    on<SignInWithGoogleInitialEvent>(signInWithGoogleInitialEvent);
  }

  Future<FutureOr<void>> signUpInitialEvent(
      SignUpInitialEvent event, Emitter<AuthenticationState> emit) async {
    emit(SignUpLoadingState());

    final user = await AuthService().signUpWithEmailAndPassword(
      event.email,
      event.password,
      event.username,
    );

    user.fold((l) {
      emit(SignUpErrorState(l.message));
    }, (r) {
      if (r == null) {
        emit(SignUpErrorState('Error signing up. Please try again.'));
      } else if (r.emailVerified == false) {
        emit(EmailNotVerified());
      } else {
        emit(SignUpSuccessfulState(r));
      }
    });
  }

  Future<FutureOr<void>> signInInitialEvent(
      SignInInitialEvent event, Emitter<AuthenticationState> emit) async {
    emit(SignInLoadingState());

    final user = await AuthService().signInWithEmailAndPassword(
      event.email,
      event.password,
    );

    user.fold((l) {
      emit(SignInErrorState(l.message));
    }, (r) {
      if (r == null) {
        emit(SignInErrorState('Error signing in. Please try again.'));
      } else if (r.emailVerified == false) {
        emit(EmailNotVerified());
      } else {
        emit(SignInSuccessfulState(r));
      }
    });
  }

  Future<FutureOr<void>> signOutInitialEvent(
      SignOutInitialEvent event, Emitter<AuthenticationState> emit) async {
    emit(SignOutLoadingState());

    try {
      await AuthService().signOut();
    } catch (e) {
      emit(SignOutErrorState('Error signing out. Please try again.'));
      return null;
    }

    emit(SignOutSuccessfulState());
  }

  FutureOr<void> passwordResetInitialEvent(
      PasswordResetInitialEvent event, Emitter<AuthenticationState> emit) {
    emit(PasswordResetLoadingState());

    try {
      AuthService().sendPasswordResetEmail(event.email);
    } catch (e) {
      emit(PasswordResetErrorState(
          'Error sending password reset email. Please try again.'));
      return null;
    }

    emit(PasswordResetSuccessfulState());
  }

  Future<FutureOr<void>> signInWithGoogleInitialEvent(
      SignInWithGoogleInitialEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(SignInWithGoogleLoadingState());

    final userCred = await AuthService().signInWithGoogle();

    if (userCred != null) {
      emit(SignInWithGoogleSuccessfulState(userCred.user!));
    } else {
      emit(SignInWithGoogleErrorState(
          'Error signing in with Google. Please try again.'));
    }
  }
}
