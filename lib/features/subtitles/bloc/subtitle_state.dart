part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleState {}

abstract class SubtitleActionState extends SubtitleState {}

final class SubtitleInitial extends SubtitleState {}

// Movie Subtitle Fetching
class SubtitleMovieFetchingLoadingState extends SubtitleState {}

class SubtitleMovieFetchingErrorState extends SubtitleState {}

class SubtitleMovieFetchingSuccessfulState extends SubtitleState {
  final SubtitlesDataUiModel subtitlesDataUiModel;

  SubtitleMovieFetchingSuccessfulState(this.subtitlesDataUiModel);
}

// TV Subtitle Fetching
class SubtitleTvFetchingLoadingState extends SubtitleState {}

class SubtitleTvFetchingErrorState extends SubtitleState {}

class SubtitleTvFetchingSuccessfulState extends SubtitleState {
  final SubtitlesDataUiModel subtitlesDataUiModel;

  SubtitleTvFetchingSuccessfulState(this.subtitlesDataUiModel);
}

// Subtitle Download
class SubtitleDownloadStartedState extends SubtitleActionState {}

class SubtitleDownloadSuccessState extends SubtitleActionState {}

class SubtitleDownloadErrorState extends SubtitleActionState {}

class SubtitleDownloadPermissionNotGrantedState extends SubtitleActionState {}
