part of 'tv_bloc.dart';

@immutable
sealed class TvEvent {}

// Trending TV
class TrendingTvInitialFetchEvent extends TvEvent {}

// On The Air TV
class OnTheAirTvInitialFetchEvent extends TvEvent {}

// TV View
class TvViewInitialFetchEvent extends TvEvent {
  final String seriesId;

  TvViewInitialFetchEvent(this.seriesId);
}

// TV Search
class TvSearchInitialFetchEvent extends TvEvent {
  final String query;

  TvSearchInitialFetchEvent(this.query);
}