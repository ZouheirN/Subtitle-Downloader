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
  }

  Future<FutureOr<void>> signUpInitialEvent(
      SignUpInitialEvent event, Emitter<AuthenticationState> emit) async {
    emit(SignUpLoadingState());

    User? user = await AuthService().signUpWithEmailAndPassword(
      event.email,
      event.password,
      event.username,
    );

    if (user == null) {
      emit(SignUpErrorState('Error signing up. Please try again.'));
    } else {
      emit(SignUpSuccessfulState(user));
    }
  }

  Future<FutureOr<void>> signInInitialEvent(
      SignInInitialEvent event, Emitter<AuthenticationState> emit) async {
    emit(SignInLoadingState());

    User? user = await AuthService().signInWithEmailAndPassword(
      event.email,
      event.password,
    );

    if (user == null) {
      emit(SignInErrorState('Error signing up. Please try again.'));
    } else {
      emit(SignInSuccessfulState(user));
    }
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
}
