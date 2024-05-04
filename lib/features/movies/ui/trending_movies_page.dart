import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_downloader/features/movies/models/trending_movies_data_ui_model.dart';

import '../bloc/movies_bloc.dart';
import 'movie_page.dart';

class TrendingMoviesPage extends StatefulWidget {
  const TrendingMoviesPage({super.key});

  @override
  State<TrendingMoviesPage> createState() => _TrendingMoviesPageState();
}

class _TrendingMoviesPageState extends State<TrendingMoviesPage> {
  final MoviesBloc moviesBloc = MoviesBloc();

  @override
  void initState() {
    moviesBloc.add(TrendingMoviesInitialFetchEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: BlocConsumer<MoviesBloc, MoviesState>(
        bloc: moviesBloc,
        listenWhen: (previous, current) => current is MoviesActionState,
        buildWhen: (previous, current) => current is! MoviesActionState,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (TrendingMoviesFetchingLoadingState):
              return const Center(child: CircularProgressIndicator());

            case const (TrendingMoviesFetchingSuccessfulState):
              final successState =
                  state as TrendingMoviesFetchingSuccessfulState;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrendingMoviesCarousel(
                        successState.trendingMoviesDataUiModel),
                    // const Padding(
                    //   padding: EdgeInsets.all(16.0),
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         'Search',
                    //         style: TextStyle(
                    //           fontSize: 32,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildTrendingMoviesCarousel(
      TrendingMoviesDataUiModel trendingMoviesDataUiModel) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(double.infinity, 571)),
      child: Swiper(
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey,
            activeColor: Colors.white,
          ),
        ),
        autoplay: true,
        viewportFraction: 0.8,
        scale: 0.8,
        itemCount: trendingMoviesDataUiModel.results!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MoviePage(
                    movieId: trendingMoviesDataUiModel.results![index].id!,
                    movieName: trendingMoviesDataUiModel.results![index].title!,
                  ),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl:
                  "https://image.tmdb.org/t/p/w500${trendingMoviesDataUiModel.results![index].posterPath!}",
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
