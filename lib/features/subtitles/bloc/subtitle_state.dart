part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleState {}

abstract class SubtitleActionState extends SubtitleState {}

final class SubtitleInitial extends SubtitleState {}

class SubtitleFetchingLoadingState extends SubtitleState {}

class SubtitleFetchingErrorState extends SubtitleState {}

class SubtitleFetchingSuccessfulState extends SubtitleState {
  final SubtitlesDataUiModel subtitlesDataUiModel;

  SubtitleFetchingSuccessfulState(this.subtitlesDataUiModel);
}

class SubtitleDownloadSuccessState extends SubtitleActionState {}

class SubtitleDownloadErrorState extends SubtitleActionState {}