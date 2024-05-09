import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:subtitle_downloader/features/tv/bloc/tv_bloc.dart';

import '../../../components/search_list.dart';
import '../../../hive/recent_searches_box.dart';
import '../models/trending_tv_data_ui_model.dart';

class HomeTvPage extends StatefulWidget {
  const HomeTvPage({super.key});

  @override
  State<HomeTvPage> createState() => _HomeTvPageState();
}

class _HomeTvPageState extends State<HomeTvPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: TvSearchDelegate());
            },
            icon: const Icon(Icons.search_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trending TV Shows',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(20),
            BlocBuilder<TvBloc, TvState>(
              bloc: TvBloc()..add(TrendingTvInitialFetchEvent()),
              buildWhen: (previous, current) =>
                  current is! TvActionState && previous != current,
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (TrendingTvFetchingLoadingState):
                    return const Center(child: CircularProgressIndicator());

                  case const (TrendingTvFetchingSuccessfulState):
                    final successState =
                        state as TrendingTvFetchingSuccessfulState;
                    return _buildTrendingTvCarousel(
                        successState.trendingTvDataUiModel);

                  default:
                    return const SizedBox();
                }
              },
            ),
            const Gap(20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'On The Air',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Gap(20),
            BlocBuilder<TvBloc, TvState>(
              bloc: TvBloc()..add(OnTheAirTvInitialFetchEvent()),
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (OnTheAirTvFetchingLoadingState):
                    return const Center(child: CircularProgressIndicator());

                  case const (OnTheAirTvFetchingSuccessfulState):
                    final successState =
                        state as OnTheAirTvFetchingSuccessfulState;
                    return Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        children: successState.onTheAirTvDataUiModel.results!
                            .map(
                              (e) => GestureDetector(
                                onTap: () {},
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

  Widget _buildTrendingTvCarousel(TrendingTvDataUiModel trendingTvDataUiModel) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size.fromHeight(350)),
      child: Swiper(
        autoplay: true,
        viewportFraction: 0.6,
        scale: 0.8,
        itemCount: trendingTvDataUiModel.results!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: CachedNetworkImage(
              imageUrl:
                  "https://image.tmdb.org/t/p/w500${trendingTvDataUiModel.results![index].posterPath!}",
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

class TvSearchDelegate extends SearchDelegate {
  final TvBloc tvBloc = TvBloc();

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
    tvBloc.add(TvSearchInitialFetchEvent(query.trim()));

    // add to recent searches
    RecentSearchesBox.addSearch(query.trim());

    return BlocBuilder<TvBloc, TvState>(
      bloc: tvBloc,
      buildWhen: (previous, current) => current is! TvActionState,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (TvSearchFetchingLoadingState):
            return const Center(child: CircularProgressIndicator());

          case const (TvSearchFetchingSuccessfulState):
            final successState = state as TvSearchFetchingSuccessfulState;
            return ListView.builder(
              itemCount: successState.tvSearchDataUiModel.results!.length,
              itemBuilder: (context, index) {
                return SearchList(
                  title: successState.tvSearchDataUiModel.results![index].name!,
                  id: successState.tvSearchDataUiModel.results![index].id!,
                  posterPath: successState
                      .tvSearchDataUiModel.results![index].posterPath,
                  voteAverage: successState
                      .tvSearchDataUiModel.results![index].voteAverage!,
                  releaseDate: successState
                      .tvSearchDataUiModel.results![index].firstAirDate
                      .toString(),
                  isMovie: false,
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
