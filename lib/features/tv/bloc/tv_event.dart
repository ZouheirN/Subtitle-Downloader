part of 'tv_bloc.dart';

@immutable
sealed class TvEvent {}

// Trending TV
class TrendingTvInitialFetchEvent extends TvEvent {}

// On The Air TV
class OnTheAirTvInitialFetchEvent extends TvEvent {}
