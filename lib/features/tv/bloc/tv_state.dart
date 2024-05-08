part of 'tv_bloc.dart';

@immutable
sealed class TvState {}

abstract class TvActionState extends TvState {}

final class TvInitial extends TvState {}

// Trending TV
class TrendingTvFetchingLoadingState extends TvState {}

class TrendingTvFetchingErrorState extends TvState {}

class TrendingTvFetchingSuccessfulState extends TvState {
  final TrendingTvDataUiModel trendingTvDataUiModel;

  TrendingTvFetchingSuccessfulState(this.trendingTvDataUiModel);
}

// OnTheAir TV
class OnTheAirTvFetchingLoadingState extends TvState {}

class OnTheAirTvFetchingErrorState extends TvState {}

class OnTheAirTvFetchingSuccessfulState extends TvState {
  final OnTheAirTvDataUiModel onTheAirTvDataUiModel;

  OnTheAirTvFetchingSuccessfulState(this.onTheAirTvDataUiModel);
}