part of 'movies_bloc.dart';

@immutable
sealed class MoviesState {}

abstract class MoviesActionState extends MoviesState {}

final class MoviesInitial extends MoviesState {}

// Trending Movies
class TrendingMoviesFetchingLoadingState extends MoviesState {}

class TrendingMoviesFetchingErrorState extends MoviesState {}

class TrendingMoviesFetchingSuccessfulState extends MoviesState {
  final TrendingMoviesDataUiModel trendingMoviesDataUiModel;

  TrendingMoviesFetchingSuccessfulState(this.trendingMoviesDataUiModel);
}

// Now Playing Movies
class NowPlayingMoviesFetchingLoadingState extends MoviesState {}

class NowPlayingMoviesFetchingErrorState extends MoviesState {}

class NowPlayingMoviesFetchingSuccessfulState extends MoviesState {
  final NowPlayingMoviesDataUiModel nowPlayingMoviesDataUiModel;

  NowPlayingMoviesFetchingSuccessfulState(this.nowPlayingMoviesDataUiModel);
}

// Movie View
class MovieViewFetchingLoadingState extends MoviesState {}

class MovieViewFetchingSuccessfulState extends MoviesState {
  final MovieDataUiModel movieDataUiModel;

  MovieViewFetchingSuccessfulState(this.movieDataUiModel);
}

class MovieViewFetchingErrorState extends MoviesState {}

// Movie Search
class MovieSearchFetchingLoadingState extends MoviesState {}

class MovieSearchFetchingSuccessfulState extends MoviesState {
  final MovieSearchDataUiModel movieDataUiModel;

  MovieSearchFetchingSuccessfulState(this.movieDataUiModel);
}

class MovieSearchFetchingErrorState extends MoviesState {}
