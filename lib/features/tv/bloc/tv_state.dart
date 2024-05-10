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

// On The Air TV
class OnTheAirTvFetchingLoadingState extends TvState {}

class OnTheAirTvFetchingErrorState extends TvState {}

class OnTheAirTvFetchingSuccessfulState extends TvState {
  final OnTheAirTvDataUiModel onTheAirTvDataUiModel;

  OnTheAirTvFetchingSuccessfulState(this.onTheAirTvDataUiModel);
}

// Tv View
class TvViewFetchingLoadingState extends TvState {}

class TvViewFetchingSuccessfulState extends TvState {
  final TvDataUiModel tvDataUiModel;

  TvViewFetchingSuccessfulState(this.tvDataUiModel);
}

class TvViewFetchingErrorState extends TvState {}

// Search TV
class TvSearchFetchingLoadingState extends TvState {}

class TvSearchFetchingSuccessfulState extends TvState {
  final TvSearchDataUiModel tvSearchDataUiModel;

  TvSearchFetchingSuccessfulState(this.tvSearchDataUiModel);
}

class TvSearchFetchingErrorState extends TvState {}
