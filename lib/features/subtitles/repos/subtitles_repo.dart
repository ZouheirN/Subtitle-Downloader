import 'package:cr_file_saver/file_saver.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle_downloader/features/subtitles/models/subtitles_data_ui_model.dart';

import '../../../main.dart';

class SubtitlesRepo {
  static Dio dio = Dio();
  static String? subdlApiKey = dotenv.env['SUBDL_API_KEY'];

  static Future<SubtitlesDataUiModel?> fetchMovieSubtitles({
    required String tmdbId,
    required String language,
    required bool includeHi,
  }) async {
    try {
      Response response = await dio.get(
        'https://api.subdl.com/api/v1/subtitles',
        queryParameters: {
          'api_key': subdlApiKey,
          'tmdb_id': tmdbId,
          'languages': language,
          'type': 'movie',
          'subs_per_page': 30,
          'hi': includeHi ? 1 : 0,
          'comment': 1,
          'releases': 1,
        },
      );

      if (response.data['status'] == false) {
        return null;
      }

      return SubtitlesDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<SubtitlesDataUiModel?> fetchTvSubtitles({
    required String tmdbId,
    required int season,
    required int episode,
    required String language,
    required bool includeHi,
  }) async {
    try {
      Response response = await dio.get(
        'https://api.subdl.com/api/v1/subtitles',
        queryParameters: {
          'api_key': subdlApiKey,
          'tmdb_id': tmdbId,
          'languages': language,
          'season_number': season,
          'episode_number': episode,
          'type': 'tv',
          'subs_per_page': 30,
          'hi': includeHi ? 1 : 0,
          'comment': 1,
          'releases': 1,
        },
      );

      if (response.data['status'] == false) {
        return null;
      }

      return SubtitlesDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<int> downloadSubtitles({
    required String url,
    required String name,
  }) async {
    try {
      String zipName =
          name.replaceFirst("SUBDL::", "").replaceFirst("SUBDL.com::", "");

      final tempDirectory = await getTemporaryDirectory();

      final tempZipFilePath = '${tempDirectory.path}/$zipName';

      await dio.download(
        'https://dl.subdl.com$url',
        tempZipFilePath,
      );

      await CRFileSaver.saveFileWithDialog(
        SaveFileDialogParams(
          sourceFilePath: tempZipFilePath,
          destinationFileName: zipName,
        ),
      );
      return 1; // Success
    } on DioException catch (e) {
      logger.e(e.toString());
      return -1; // Error
    }
  }

  static Future<SubtitlesDataUiModel?> fetchSubtitlesFromFileName({
    required String fileName,
    required bool includeHi,
  }) async {
    try {
      Response response = await dio.get(
        'https://api.subdl.com/api/v1/subtitles',
        queryParameters: {
          'api_key': subdlApiKey,
          'file_name': fileName,
          'subs_per_page': 30,
          'hi': includeHi ? 1 : 0,
          'comment': 1,
          'releases': 1,
        },
      );

      if (response.data['status'] == false) {
        return null;
      }

      return SubtitlesDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }
}
