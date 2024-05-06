import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/components/movie_search_list.dart';
import 'package:subtitle_downloader/features/movies/models/trending_movies_data_ui_model.dart';
import 'package:subtitle_downloader/hive/recent_searches_box.dart';

import '../bloc/movies_bloc.dart';

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
        title: const Text('Movies'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MySearchDelegate());
              },
              icon: const Icon(Icons.search_rounded))
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
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Trending Movies',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildTrendingMoviesCarousel(
                        successState.trendingMoviesDataUiModel),
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
              context.pushNamed('View Movie', pathParameters: {
                'movieId':
                    trendingMoviesDataUiModel.results![index].id.toString(),
                'movieName': trendingMoviesDataUiModel.results![index].title!,
              });
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

class MySearchDelegate extends SearchDelegate {
  final MoviesBloc moviesBloc = MoviesBloc();

  MySearchDelegate() {
    // todo: add discover
    // moviesBloc.add(MovieSearchInitialFetchEvent(query));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear_rounded),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    moviesBloc.add(MovieSearchInitialFetchEvent(query));

    // add to recent searches
    RecentSearchesBox.addSearch(query);

    return BlocConsumer<MoviesBloc, MoviesState>(
      bloc: moviesBloc,
      listenWhen: (previous, current) => current is MoviesActionState,
      buildWhen: (previous, current) => current is! MoviesActionState,
      listener: (context, state) {},
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (MovieSearchFetchingLoadingState):
            return const Center(child: CircularProgressIndicator());

          case const (MovieSearchFetchingSuccessfulState):
            final successState = state as MovieSearchFetchingSuccessfulState;
            return ListView.builder(
              itemCount: successState.movieDataUiModel.results!.length,
              itemBuilder: (context, index) {
                return MovieSearchList(
                  title: successState.movieDataUiModel.results![index].title!,
                  id: successState.movieDataUiModel.results![index].id!,
                  posterPath:
                      successState.movieDataUiModel.results![index].posterPath,
                  voteAverage: successState
                      .movieDataUiModel.results![index].voteAverage!,
                  releaseDate: successState
                      .movieDataUiModel.results![index].releaseDate!,
                );
              },
            );

          default:
            return const SizedBox();
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searches = RecentSearchesBox.getSearches();
    return StatefulBuilder(
      builder: (context, setState) => ListView.builder(
        itemCount: searches.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searches[index]),
            onTap: () {
              query = searches[index];
            },
            leading: const Icon(Icons.history_rounded),
            trailing: IconButton(
              onPressed: () {
                RecentSearchesBox.removeSearch(searches[index]);
                setState(() => searches.removeAt(index));
              },
              icon: const Icon(Icons.delete_rounded),
            ),
          );
        },
      ),
    );
  }
}
