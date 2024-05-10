part of 'movies_bloc.dart';

@immutable
sealed class MoviesState {}

abstract class MoviesActionState extends MoviesState {}

abstract class TrendingMoviesState extends MoviesState {}

abstract class NowPlayingMoviesState extends MoviesState {}

abstract class MovieViewState extends MoviesState {}

abstract class MovieSearchState extends MoviesState {}

final class MoviesInitial extends MoviesState {}

// Trending Movies
class TrendingMoviesFetchingLoadingState extends TrendingMoviesState {}

class TrendingMoviesFetchingErrorState extends TrendingMoviesState {}

class TrendingMoviesFetchingSuccessfulState extends TrendingMoviesState {
  final TrendingMoviesDataUiModel trendingMoviesDataUiModel;

  TrendingMoviesFetchingSuccessfulState(this.trendingMoviesDataUiModel);
}

// Now Playing Movies
class NowPlayingMoviesFetchingLoadingState extends NowPlayingMoviesState {}

class NowPlayingMoviesFetchingErrorState extends NowPlayingMoviesState {}

class NowPlayingMoviesFetchingSuccessfulState extends NowPlayingMoviesState {
  final NowPlayingMoviesDataUiModel nowPlayingMoviesDataUiModel;

  NowPlayingMoviesFetchingSuccessfulState(this.nowPlayingMoviesDataUiModel);
}

// Movie View
class MovieViewFetchingLoadingState extends MovieViewState {}

class MovieViewFetchingSuccessfulState extends MovieViewState {
  final MovieDataUiModel movieDataUiModel;

  MovieViewFetchingSuccessfulState(this.movieDataUiModel);
}

class MovieViewFetchingErrorState extends MovieViewState {}

// Movie Search
class MovieSearchFetchingLoadingState extends MovieSearchState {}

class MovieSearchFetchingSuccessfulState extends MovieSearchState {
  final MovieSearchDataUiModel movieDataUiModel;

  MovieSearchFetchingSuccessfulState(this.movieDataUiModel);
}

class MovieSearchFetchingErrorState extends MovieSearchState {}
