import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/movies/models/movie_data_ui_model.dart';
import 'package:subtitle_downloader/features/movies/models/movie_search_data_ui_model.dart';

import '../models/now_playing_movies_data_ui_model.dart';
import '../models/trending_movies_data_ui_model.dart';
import '../repos/movies_repo.dart';

part 'movies_event.dart';
part 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc() : super(MoviesInitial()) {
    on<TrendingMoviesInitialFetchEvent>(moviesInitialFetchEvent);
    on<MovieViewInitialFetchEvent>(movieViewInitialFetchEvent);
    on<MovieSearchInitialFetchEvent>(movieSearchInitialFetchEvent);
    on<NowPlayingMoviesInitialFetchEvent>(nowPlayingMoviesInitialFetchEvent);
  }

  FutureOr<void> moviesInitialFetchEvent(
      TrendingMoviesInitialFetchEvent event, Emitter<MoviesState> emit) async {
    emit(TrendingMoviesFetchingLoadingState());

    TrendingMoviesDataUiModel? trendingMoviesDataUiModel =
        await MoviesRepo.fetchTrendingMovies();

    if (trendingMoviesDataUiModel == null) {
      emit(TrendingMoviesFetchingErrorState());
    } else {
      emit(TrendingMoviesFetchingSuccessfulState(trendingMoviesDataUiModel));
    }
  }

  Future<FutureOr<void>> movieViewInitialFetchEvent(
      MovieViewInitialFetchEvent event, Emitter<MoviesState> emit) async {
    emit(MovieViewFetchingLoadingState());

    MovieDataUiModel? movieDataUiModel =
        await MoviesRepo.viewMovie(movieId: event.movieId);

    if (movieDataUiModel == null) {
      emit(MovieViewFetchingErrorState());
    } else {
      emit(MovieViewFetchingSuccessfulState(movieDataUiModel));
    }
  }

  Future<FutureOr<void>> movieSearchInitialFetchEvent(
      MovieSearchInitialFetchEvent event, Emitter<MoviesState> emit) async {
    emit(MovieSearchFetchingLoadingState());

    MovieSearchDataUiModel? movieSearchDataUiModel =
        await MoviesRepo.searchMovie(
      query: event.query,
    );

    if (movieSearchDataUiModel == null) {
      emit(MovieSearchFetchingErrorState());
    } else {
      emit(MovieSearchFetchingSuccessfulState(movieSearchDataUiModel));
    }
  }

  Future<FutureOr<void>> nowPlayingMoviesInitialFetchEvent(
      NowPlayingMoviesInitialFetchEvent event,
      Emitter<MoviesState> emit) async {
    emit(NowPlayingMoviesFetchingLoadingState());

    NowPlayingMoviesDataUiModel? nowPlayingMoviesDataUiModel =
        await MoviesRepo.fetchNowPlayingMovies();

    if (nowPlayingMoviesDataUiModel == null) {
      emit(NowPlayingMoviesFetchingErrorState());
    } else {
      emit(
          NowPlayingMoviesFetchingSuccessfulState(nowPlayingMoviesDataUiModel));
    }
  }
}
