import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/main.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ChangeProfilePictureEvent>(changeProfilePictureEvent);
    on<GetProfilePictureEvent>(getProfilePictureEvent);
  }

  Future<void> changeProfilePictureEvent(
      ChangeProfilePictureEvent event, Emitter<ProfileState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(ChangeProfilePictureErrorState('User not logged in.'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    emit(ChangeProfilePictureLoadingState());

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(
        'profile_pictures/${FirebaseAuth.instance.currentUser?.uid}.jpg');

    try {
      final imageBytes = await image.readAsBytes();
      await imageRef.putData(imageBytes);
      emit(ChangeProfilePictureSuccessfulState(imageBytes));
    } catch (e) {
      emit(ChangeProfilePictureErrorState(e.toString()));
    }
  }

  FutureOr<void> getProfilePictureEvent(
      GetProfilePictureEvent event, Emitter<ProfileState> emit) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final storageRef = FirebaseStorage.instance.ref();

    try {
      final imageRef = storageRef.child(
          'profile_pictures/${FirebaseAuth.instance.currentUser?.uid}.jpg');

      final imageBytes = await imageRef.getData();

      if (imageBytes == null) return;

      emit(GetProfilePictureSuccessfulState(imageBytes));
    } catch (e) {
      logger.e(e.toString());
    }
  }
}
