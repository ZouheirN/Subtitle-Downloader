part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleEvent {}

// Movie Subtitles
class SubtitleMovieInitialFetchEvent extends SubtitleEvent {
  final String movieId;
  final String language;

  SubtitleMovieInitialFetchEvent(this.movieId, this.language);
}

// TV Subtitles
class SubtitleTvInitialFetchEvent extends SubtitleEvent {
  final String tvId;
  final int season;
  final int episode;
  final String language;

  SubtitleTvInitialFetchEvent(
      this.tvId, this.season, this.episode, this.language);
}

class SubtitleDownloadEvent extends SubtitleEvent {
  final String url;
  final String name;
  final String author;
  final String releaseName;
  final String mediaName;
  final String type;

  SubtitleDownloadEvent(this.url, this.name, this.author, this.releaseName,
      this.mediaName, this.type);
}
