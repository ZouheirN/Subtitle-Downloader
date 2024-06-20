part of 'subtitle_bloc.dart';

@immutable
sealed class SubtitleEvent {}

// Movie Subtitles
class SubtitleMovieInitialFetchEvent extends SubtitleEvent {
  final String movieId;
  final String language;
  final bool includeHi;

  SubtitleMovieInitialFetchEvent(this.movieId, this.language, this.includeHi);
}

// TV Subtitles
class SubtitleTvInitialFetchEvent extends SubtitleEvent {
  final String tvId;
  final int season;
  final int episode;
  final String language;
  final bool includeHi;

  SubtitleTvInitialFetchEvent(
      this.tvId, this.season, this.episode, this.language, this.includeHi);
}

// Download Subtitles
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

// Fetch Subtitles from file name
class SubtitleInitialFetchFromFileName extends SubtitleEvent {
  final String fileName;
  final String language;
  final bool includeHi;

  SubtitleInitialFetchFromFileName(this.fileName,this.language, this.includeHi);
}