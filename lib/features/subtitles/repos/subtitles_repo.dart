import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
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
      String newName = name.replaceFirst("SUBDL::", "");

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return 0; // Canceled

      final tempZipFilePath =
          '${(await getTemporaryDirectory()).path}/$newName';

      await dio.download(
        'https://dl.subdl.com$url',
        tempZipFilePath,
      );

      // extract the archive
      final zipFile = File(tempZipFilePath);
      final destinationDir = Directory(selectedDirectory);
      try {
        ZipFile.extractToDirectory(
            zipFile: zipFile, destinationDir: destinationDir);
      } catch (e) {
        logger.e(e.toString());
        return -1; // Error
      }

      return 1; // Success
    } on DioException catch (e) {
      logger.e(e.toString());
      return -1; // Error
    }
  }
}
