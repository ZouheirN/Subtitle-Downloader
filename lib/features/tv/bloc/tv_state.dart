part of 'tv_bloc.dart';

@immutable
sealed class TvState {}

abstract class TvActionState extends TvState {}

abstract class TrendingTvState extends TvState {}

abstract class OnTheAirTvState extends TvState {}

abstract class TvSearchState extends TvState {}

final class TvInitial extends TvState {}

// Trending TV
class TrendingTvFetchingLoadingState extends TrendingTvState {}

class TrendingTvFetchingErrorState extends TrendingTvState {}

class TrendingTvFetchingSuccessfulState extends TrendingTvState {
  final TrendingTvDataUiModel trendingTvDataUiModel;

  TrendingTvFetchingSuccessfulState(this.trendingTvDataUiModel);
}

// On The Air TV
class OnTheAirTvFetchingLoadingState extends OnTheAirTvState {}

class OnTheAirTvFetchingErrorState extends OnTheAirTvState {}

class OnTheAirTvFetchingSuccessfulState extends OnTheAirTvState {
  final OnTheAirTvDataUiModel onTheAirTvDataUiModel;

  OnTheAirTvFetchingSuccessfulState(this.onTheAirTvDataUiModel);
}

// Search TV
class TvSearchFetchingLoadingState extends TvSearchState {}

class TvSearchFetchingSuccessfulState extends TvSearchState {
  final TvSearchDataUiModel tvSearchDataUiModel;

  TvSearchFetchingSuccessfulState(this.tvSearchDataUiModel);
}

class TvSearchFetchingErrorState extends TvSearchState {}
