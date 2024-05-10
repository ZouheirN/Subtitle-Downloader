import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/components/search_list.dart';
import 'package:subtitle_downloader/features/movies/models/trending_movies_data_ui_model.dart';
import 'package:subtitle_downloader/hive/recent_searches_box.dart';

import '../bloc/movies_bloc.dart';

class HomeMoviesPage extends StatefulWidget {
  const HomeMoviesPage({super.key});

  @override
  State<HomeMoviesPage> createState() => _HomeMoviesPageState();
}

class _HomeMoviesPageState extends State<HomeMoviesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MovieSearchDelegate());
              },
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Gap(20),
            BlocBuilder<MoviesBloc, MoviesState>(
              bloc: context.read<MoviesBloc>()..add(TrendingMoviesInitialFetchEvent()),
              buildWhen: (previous, current) => current is TrendingMoviesState,
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (TrendingMoviesFetchingLoadingState):
                    return const Center(child: CircularProgressIndicator());

                  case const (TrendingMoviesFetchingSuccessfulState):
                    final successState =
                        state as TrendingMoviesFetchingSuccessfulState;
                    return _buildTrendingMoviesCarousel(
                        successState.trendingMoviesDataUiModel);

                  default:
                    return const SizedBox();
                }
              },
            ),
            const Gap(20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Now Playing',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(20),
            BlocBuilder<MoviesBloc, MoviesState>(
              bloc: context.read<MoviesBloc>()..add(NowPlayingMoviesInitialFetchEvent()),
              buildWhen: (previous, current) => current is NowPlayingMoviesState,
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (NowPlayingMoviesFetchingLoadingState):
                    return const Center(child: CircularProgressIndicator());

                  case const (NowPlayingMoviesFetchingSuccessfulState):
                    final successState =
                        state as NowPlayingMoviesFetchingSuccessfulState;
                    return Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        children: successState
                            .nowPlayingMoviesDataUiModel.results!
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  context
                                      .pushNamed('View Movie', pathParameters: {
                                    'movieId': e.id.toString(),
                                    'movieName': e.title!,
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "https://image.tmdb.org/t/p/w500${e.posterPath!}",
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        width: 150,
                                        height: 225,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return Container(
                                        width: 150,
                                        height: 225,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey[100]!
                                              .withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: progress.progress,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );

                  default:
                    return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingMoviesCarousel(
      TrendingMoviesDataUiModel trendingMoviesDataUiModel) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size.fromHeight(350)),
      child: Swiper(
        autoplay: true,
        viewportFraction: 0.6,
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
              imageBuilder: (context, imageProvider) {
                return Container(
                  width: 150,
                  height: 225,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              progressIndicatorBuilder: (context, url, progress) {
                return Container(
                  width: 150,
                  height: 225,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100]!.withOpacity(0.1),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  MovieSearchDelegate() {
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
    context.read<MoviesBloc>().add(MovieSearchInitialFetchEvent(query.trim()));

    // add to recent searches
    RecentSearchesBox.addSearch(query.trim());

    return BlocBuilder<MoviesBloc, MoviesState>(
      bloc: context.read<MoviesBloc>(),
      buildWhen: (previous, current) => current is MovieSearchState,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (MovieSearchFetchingLoadingState):
            return const Center(child: CircularProgressIndicator());

          case const (MovieSearchFetchingSuccessfulState):
            final successState = state as MovieSearchFetchingSuccessfulState;
            return ListView.builder(
              itemCount: successState.movieDataUiModel.results!.length,
              itemBuilder: (context, index) {
                return SearchList(
                  title: successState.movieDataUiModel.results![index].title!,
                  id: successState.movieDataUiModel.results![index].id!,
                  posterPath:
                      successState.movieDataUiModel.results![index].posterPath,
                  voteAverage: successState
                      .movieDataUiModel.results![index].voteAverage!,
                  releaseDate: successState
                      .movieDataUiModel.results![index].releaseDate!,
                  isMovie: true,
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
