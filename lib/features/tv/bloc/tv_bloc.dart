import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/tv/models/trending_tv_data_ui_model.dart';
import 'package:subtitle_downloader/features/tv/repos/tv_repo.dart';

import '../models/on_the_air_tv_data_ui_model.dart';

part 'tv_event.dart';

part 'tv_state.dart';

class TvBloc extends Bloc<TvEvent, TvState> {
  TvBloc() : super(TvInitial()) {
    on<TrendingTvInitialFetchEvent>(trendingTVInitialFetchEvent);
    on<OnTheAirTvInitialFetchEvent>(onTheAirTvInitialFetchEvent);
  }

  Future<FutureOr<void>> trendingTVInitialFetchEvent(
      TrendingTvInitialFetchEvent event, Emitter<TvState> emit) async {
    emit(TrendingTvFetchingLoadingState());

    TrendingTvDataUiModel? trendingTvDataUiModel =
        await TvRepo.fetchTrendingTv();

    if (trendingTvDataUiModel == null) {
      emit(TrendingTvFetchingErrorState());
    } else {
      emit(TrendingTvFetchingSuccessfulState(trendingTvDataUiModel));
    }
  }

  FutureOr<void> onTheAirTvInitialFetchEvent(
      OnTheAirTvInitialFetchEvent event, Emitter<TvState> emit) async {
    emit(OnTheAirTvFetchingLoadingState());

    OnTheAirTvDataUiModel? onTheAirTvDataUiModel =
        await TvRepo.fetchOnTheAirTv();

    if (onTheAirTvDataUiModel == null) {
      emit(OnTheAirTvFetchingErrorState());
    } else {
      emit(OnTheAirTvFetchingSuccessfulState(onTheAirTvDataUiModel));
    }
  }
}
