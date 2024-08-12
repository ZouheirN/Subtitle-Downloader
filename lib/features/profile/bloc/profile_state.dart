part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

// Change Profile Picture
class ChangeProfilePictureLoadingState extends ProfileState {}

class ChangeProfilePictureErrorState extends ProfileState {
  final String errorMessage;

  ChangeProfilePictureErrorState(this.errorMessage);
}

class ChangeProfilePictureSuccessfulState extends ProfileState {
  final Uint8List imageBytes;

  ChangeProfilePictureSuccessfulState(this.imageBytes);
}

// Get Profile Picture
class GetProfilePictureSuccessfulState extends ProfileState {
  final Uint8List imageBytes;

  GetProfilePictureSuccessfulState(this.imageBytes);
}