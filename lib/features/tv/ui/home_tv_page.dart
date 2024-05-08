import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:subtitle_downloader/features/tv/bloc/tv_bloc.dart';

import '../../movies/ui/home_movies_page.dart';
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
              showSearch(context: context, delegate: MySearchDelegate());
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
