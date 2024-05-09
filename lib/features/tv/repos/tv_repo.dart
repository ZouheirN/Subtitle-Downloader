import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:subtitle_downloader/features/tv/models/on_the_air_tv_data_ui_model.dart';

import '../../../main.dart';
import '../models/trending_tv_data_ui_model.dart';
import '../models/tv_search_data_ui_model.dart';

class TvRepo {
  static Dio dio = Dio();
  static String? tmdbApiKey = dotenv.env['TMBD_API_KEY'];

  static Future<TrendingTvDataUiModel?> fetchTrendingTv() async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/trending/tv/day?language=en-US',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return TrendingTvDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<OnTheAirTvDataUiModel?> fetchOnTheAirTv() async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/tv/on_the_air?language=en-US&page=1',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return OnTheAirTvDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<TvSearchDataUiModel?> searchTv({required String query}) async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/search/tv?query=$query&language=en-US',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return TvSearchDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }
}
