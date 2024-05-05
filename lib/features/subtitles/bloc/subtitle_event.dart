part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleEvent {}

class SubtitleInitialFetchEvent extends SubtitleEvent {
  final String movieId;
  final String language;

  SubtitleInitialFetchEvent(this.movieId, {this.language = 'en'});
}
