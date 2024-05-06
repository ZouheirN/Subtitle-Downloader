import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/subtitles/models/subtitles_data_ui_model.dart';

import '../repos/subtitles_repo.dart';

part 'subtitle_event.dart';
part 'subtitle_state.dart';

class SubtitleBloc extends Bloc<SubtitleEvent, SubtitleState> {
  SubtitleBloc() : super(SubtitleInitial()) {
    on<SubtitleInitialFetchEvent>(subtitleInitialFetchEvent);
    on<SubtitleDownloadEvent>(subtitleDownloadEvent);
  }

  Future<FutureOr<void>> subtitleInitialFetchEvent(
      SubtitleInitialFetchEvent event, Emitter<SubtitleState> emit) async {
    emit(SubtitleFetchingLoadingState());

    SubtitlesDataUiModel? subtitlesDataUiModel =
        await SubtitlesRepo.fetchSubtitles(
      tmdbId: event.movieId,
      language: event.language,
      type: event.type,
    );

    if (subtitlesDataUiModel == null) {
      emit(SubtitleFetchingErrorState());
    } else {
      emit(SubtitleFetchingSuccessfulState(subtitlesDataUiModel));
    }
  }

  Future<FutureOr<void>> subtitleDownloadEvent(
      SubtitleDownloadEvent event, Emitter<SubtitleState> emit) async {
    int response = await SubtitlesRepo.downloadSubtitles(
      url: event.url,
      name: event.name,
    );

    if (response == 1) {
      emit(SubtitleDownloadSuccessState());
    } else if (response == -1) {
      emit(SubtitleDownloadErrorState());
    }
  }
}