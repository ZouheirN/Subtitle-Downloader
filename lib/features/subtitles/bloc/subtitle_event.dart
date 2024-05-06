part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleEvent {}

class SubtitleInitialFetchEvent extends SubtitleEvent {
  final String movieId;
  final String language;
  final String type;

  SubtitleInitialFetchEvent(this.movieId, this.language, this.type);
}

class SubtitleDownloadEvent extends SubtitleEvent {
  final String url;
  final String name;

  SubtitleDownloadEvent(this.url, this.name);
}
