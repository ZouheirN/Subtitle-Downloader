part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

// Change Profile Picture
class ChangeProfilePictureEvent extends ProfileEvent {}

// Get Profile Picture
class GetProfilePictureEvent extends ProfileEvent {}