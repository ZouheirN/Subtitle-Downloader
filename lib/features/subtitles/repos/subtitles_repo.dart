import 'package:cr_file_saver/file_saver.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
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
          'subs_per_page': 30,
        },
      );

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
      String zipName = name.replaceFirst("SUBDL::", "");
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
}
