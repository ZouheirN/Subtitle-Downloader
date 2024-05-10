part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleState {}

abstract class SubtitleActionState extends SubtitleState {}

abstract class SubtitleFetchingState extends SubtitleState {}

final class SubtitleInitial extends SubtitleState {}

// Subtitle Fetching
class SubtitleFetchingLoadingState extends SubtitleFetchingState {}

class SubtitleFetchingErrorState extends SubtitleFetchingState {}

class SubtitleFetchingSuccessfulState extends SubtitleFetchingState {
  final SubtitlesDataUiModel subtitlesDataUiModel;

  SubtitleFetchingSuccessfulState(this.subtitlesDataUiModel);
}

// Subtitle Download
class SubtitleDownloadStartedState extends SubtitleActionState {}

class SubtitleDownloadSuccessState extends SubtitleActionState {}

class SubtitleDownloadErrorState extends SubtitleActionState {}

class SubtitleDownloadPermissionNotGrantedState extends SubtitleActionState {}
