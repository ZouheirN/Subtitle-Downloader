import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subtitle_downloader/features/profile/repos/profile_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ChangeProfilePictureEvent>(changeProfilePictureEvent);
    on<GetProfilePictureEvent>(getProfilePictureEvent);
    on<DeleteAccountEvent>(deleteAccountEvent);
    on<ClearProfilePictureEvent>((event, emit) {
      emit(ClearProfilePictureState());
    });
  }

  Future<void> changeProfilePictureEvent(
      ChangeProfilePictureEvent event, Emitter<ProfileState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(ChangeProfilePictureErrorState('You are not logged in'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    emit(ChangeProfilePictureLoadingState());

    final imageBytes = await ProfileRepo().changeProfilePicture(image);

    if (imageBytes == null) {
      emit(ChangeProfilePictureErrorState('Failed to change profile picture'));
    } else {
      emit(ChangeProfilePictureSuccessfulState(imageBytes));
    }
  }

  FutureOr<void> getProfilePictureEvent(
      GetProfilePictureEvent event, Emitter<ProfileState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final imageBytes = await ProfileRepo().getProfilePicture();

    emit(GetProfilePictureSuccessfulState(imageBytes));
  }

  FutureOr<void> deleteAccountEvent(
      DeleteAccountEvent event, Emitter<ProfileState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(DeleteAccountErrorState('You are not logged in'));
      return;
    }

    emit(DeleteAccountLoadingState());

    final result = await ProfileRepo().deleteAccount();

    result.fold(
      (l) => emit(DeleteAccountErrorState(l.message)),
      (r) => emit(DeleteAccountSuccessfulState()),
    );
  }
}
