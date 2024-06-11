import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:meta/meta.dart';
import 'package:subtitle_downloader/features/subtitles/models/subtitles_data_ui_model.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';

import '../repos/subtitles_repo.dart';

part 'subtitle_event.dart';

part 'subtitle_state.dart';

class SubtitleBloc extends Bloc<SubtitleEvent, SubtitleState> {
  SubtitleBloc() : super(SubtitleInitial()) {
    on<SubtitleMovieInitialFetchEvent>(subtitleMovieInitialFetchEvent);
    on<SubtitleDownloadEvent>(subtitleDownloadEvent);
    on<SubtitleTvInitialFetchEvent>(subtitleTvInitialFetchEvent);
  }

  Future<FutureOr<void>> subtitleMovieInitialFetchEvent(
      SubtitleMovieInitialFetchEvent event, Emitter<SubtitleState> emit) async {
    emit(SubtitleMovieFetchingLoadingState());

    SubtitlesDataUiModel? subtitlesDataUiModel =
        await SubtitlesRepo.fetchMovieSubtitles(
      tmdbId: event.movieId,
      language: event.language,
      includeHi: event.includeHi,
    );

    if (subtitlesDataUiModel == null) {
      emit(SubtitleMovieFetchingErrorState());
    } else {
      emit(SubtitleMovieFetchingSuccessfulState(subtitlesDataUiModel));
    }
  }

  Future<FutureOr<void>> subtitleDownloadEvent(
      SubtitleDownloadEvent event, Emitter<SubtitleState> emit) async {
    final granted = await CRFileSaver.requestWriteExternalStoragePermission();

    if (granted) {
      emit(SubtitleDownloadStartedState());

      int response = await SubtitlesRepo.downloadSubtitles(
        url: event.url,
        name: event.name,
      );

      if (response == 1) {
        DownloadedSubtitlesBox.addDownloadedSubtitle(
            event.url, event.releaseName, event.author, event.mediaName);
        emit(SubtitleDownloadSuccessState());
      } else if (response == -1) {
        emit(SubtitleDownloadErrorState());
      }
    } else {
      emit(SubtitleDownloadPermissionNotGrantedState());
    }
  }

  Future<FutureOr<void>> subtitleTvInitialFetchEvent(
      SubtitleTvInitialFetchEvent event, Emitter<SubtitleState> emit) async {
    emit(SubtitleTvFetchingLoadingState());

    SubtitlesDataUiModel? subtitlesDataUiModel =
        await SubtitlesRepo.fetchTvSubtitles(
      tmdbId: event.tvId,
      season: event.season,
      episode: event.episode,
      language: event.language,
      includeHi: event.includeHi,
    );

    if (subtitlesDataUiModel == null) {
      emit(SubtitleTvFetchingErrorState());
    } else {
      emit(SubtitleTvFetchingSuccessfulState(subtitlesDataUiModel));
    }
  }
}
