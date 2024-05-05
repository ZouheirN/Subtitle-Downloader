import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../main.dart';
import '../models/movie_data_ui_model.dart';
import '../models/movie_search_data_ui_model.dart';
import '../models/trending_movies_data_ui_model.dart';

class MoviesRepo {
  static Dio dio = Dio();
  static String? tmdbApiKey = dotenv.env['TMBD_API_KEY'];

  static Future<TrendingMoviesDataUiModel?> fetchTrendingMovies() async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/trending/movie/week?language=en-US',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return TrendingMoviesDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<MovieDataUiModel?> viewMovie({required int movieId}) async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/movie/$movieId?language=en-US',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return MovieDataUiModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  static Future<MovieSearchDataUiModel?> searchMovie(
      {required String query}) async {
    try {
      Response response = await dio.get(
        'https://api.themoviedb.org/3/search/movie?query=$query&language=en-US',
        options: Options(
          headers: {
            'Authorization': 'Bearer $tmdbApiKey',
          },
        ),
      );

      return MovieSearchDataUiModel.fromJson(response.data);
      } on DioException catch (e) {
      logger.e(e.toString());
      return null;
    }
  }
}
