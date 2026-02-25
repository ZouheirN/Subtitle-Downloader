import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/tv/models/trending_tv_data_ui_model.dart';
import 'package:subtitle_downloader/features/tv/repos/tv_repo.dart';

import '../models/on_the_air_tv_data_ui_model.dart';
import '../models/tv_data_ui_model.dart';
import '../models/tv_search_data_ui_model.dart';

part 'tv_event.dart';
part 'tv_state.dart';

class TvBloc extends Bloc<TvEvent, TvState> {
  TvBloc() : super(TvInitial()) {
    on<TrendingTvInitialFetchEvent>(trendingTVInitialFetchEvent);
    on<OnTheAirTvInitialFetchEvent>(onTheAirTvInitialFetchEvent);
    on<TvSearchInitialFetchEvent>(tvSearchInitialFetchEvent);
    on<TvViewInitialFetchEvent>(tvViewInitialFetchEvent);
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

  Future<FutureOr<void>> tvViewInitialFetchEvent(
      TvViewInitialFetchEvent event, Emitter<TvState> emit) async {
    emit(TvViewFetchingLoadingState());

    TvDataUiModel? tvDataUiModel =
        await TvRepo.viewTv(seriesId: event.seriesId);

    if (tvDataUiModel == null) {
      emit(TvViewFetchingErrorState());
    } else {
      emit(TvViewFetchingSuccessfulState(tvDataUiModel));
    }
  }

  Future<FutureOr<void>> tvSearchInitialFetchEvent(
      event, Emitter<TvState> emit) async {
    emit(TvSearchFetchingLoadingState());

    TvSearchDataUiModel? tvSearchDataUiModel = await TvRepo.searchTv(
      query: event.query,
    );

    if (tvSearchDataUiModel == null) {
      emit(TvSearchFetchingErrorState());
    } else {
      emit(TvSearchFetchingSuccessfulState(tvSearchDataUiModel));
    }
  }
}
