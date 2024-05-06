import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:subtitle_downloader/features/subtitles/models/subtitles_data_ui_model.dart';

import '../../../main.dart';

class SubtitlesRepo {
  static Dio dio = Dio();
  static String? subdlApiKey = dotenv.env['SUBDL_API_KEY'];

  static Future<SubtitlesDataUiModel?> fetchSubtitles({
    required String tmdbId,
    required String language,
    required String type,
  }) async {
    try {
      Response response = await dio.get(
        'https://api.subdl.com/api/v1/subtitles',
        queryParameters: {
          'api_key': subdlApiKey,
          'tmdb_id': tmdbId,
          'languages': language,
          'type': type,
        },
      );

      return SubtitlesDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }
}
