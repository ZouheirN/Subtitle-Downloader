part of 'movies_bloc.dart';

@immutable
sealed class MoviesEvent {}

// Trending Movies
class TrendingMoviesInitialFetchEvent extends MoviesEvent {}

// Now Playing Movies
class NowPlayingMoviesInitialFetchEvent extends MoviesEvent {}

// Movie View
class MovieViewInitialFetchEvent extends MoviesEvent {
  final int movieId;

  MovieViewInitialFetchEvent(this.movieId);
}

// Movie Search
class MovieSearchInitialFetchEvent extends MoviesEvent {
  final String query;

  MovieSearchInitialFetchEvent(this.query);
}