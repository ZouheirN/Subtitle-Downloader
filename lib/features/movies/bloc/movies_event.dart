part of 'movies_bloc.dart';

@immutable
sealed class MoviesEvent {}

class TrendingMoviesInitialFetchEvent extends MoviesEvent {}

class MovieViewInitialFetchEvent extends MoviesEvent {
  final int movieId;

  MovieViewInitialFetchEvent(this.movieId);
}
