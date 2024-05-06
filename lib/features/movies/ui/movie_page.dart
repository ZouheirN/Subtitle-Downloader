import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:subtitle_downloader/components/language_dropdown.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';

import '../../subtitles/models/subtitles_data_ui_model.dart';
import '../bloc/movies_bloc.dart';
import '../models/movie_data_ui_model.dart';

class MoviePage extends StatefulWidget {
  final int movieId;
  final String movieName;

  const MoviePage({super.key, required this.movieId, required this.movieName});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MoviesBloc movieBloc = MoviesBloc();
  final SubtitleBloc subtitleBloc = SubtitleBloc();
  bool showMorePressed = false;
  String? oldLanguage;

  void onLanguageChanged(String language) {
    if (oldLanguage == language) return;
    oldLanguage = language;

    subtitleBloc.add(
      SubtitleInitialFetchEvent(
        widget.movieId.toString(),
        language,
        'movie',
      ),
    );
  }

  @override
  void initState() {
    movieBloc.add(MovieViewInitialFetchEvent(widget.movieId));
    subtitleBloc.add(
      SubtitleInitialFetchEvent(
        widget.movieId.toString(),
        'EN',
        'movie',
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MoviesBloc, MoviesState>(
        bloc: movieBloc,
        listenWhen: (previous, current) => current is MoviesActionState,
        buildWhen: (previous, current) => current is! MoviesActionState,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (MovieViewFetchingLoadingState):
              return const Center(child: CircularProgressIndicator());

            case const (MovieViewFetchingSuccessfulState):
              final successState = state as MovieViewFetchingSuccessfulState;
              return _buildMovieView(successState.movieDataUiModel);

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildMovieView(MovieDataUiModel movieDataUiModel) {
    final datePared = DateTime.tryParse(
        movieDataUiModel.releaseDate?.toIso8601String() ?? '');

    final genres = movieDataUiModel.genres?.map(
      (e) {
        return e.name;
      },
    ).join(', ');

    int hours = movieDataUiModel.runtime! ~/ 60;
    int remainingMinutes = movieDataUiModel.runtime! % 60;
    String hoursString = hours > 0 ? '${hours}h' : '';
    String minutesString = remainingMinutes > 0 ? '${remainingMinutes}m' : '';
    final runtime = '$hoursString $minutesString';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            // centerTitle: true,
            title: Text(
              movieDataUiModel.title ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            background: CachedNetworkImage(
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${movieDataUiModel.backdropPath}',
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  const SizedBox(),
              alignment: Alignment.topCenter,
              imageBuilder: (context, imageProvider) {
                return ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          pinned: true,
          expandedHeight: 200,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        datePared != null
                            ? '${datePared.year} • $genres • $runtime'
                            : 'No Release Date',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Gap(8),
                      if (!showMorePressed)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showMorePressed = true;
                            });
                          },
                          child: Text(
                            movieDataUiModel.overview ?? 'No Overview',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showMorePressed = false;
                            });
                          },
                          child:
                              Text(movieDataUiModel.overview ?? 'No Overview'),
                        ),
                      const Gap(16),
                      const Divider(),
                      const Gap(16),
                      BlocConsumer<SubtitleBloc, SubtitleState>(
                        bloc: subtitleBloc,
                        listenWhen: (previous, current) =>
                            current is SubtitleActionState,
                        buildWhen: (previous, current) =>
                            current is! SubtitleActionState,
                        listener: (context, state) {
                          switch (state.runtimeType) {
                            case const (SubtitleDownloadSuccessState):
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subtitle Downloaded'),
                                ),
                              );
                              break;
                            case const (SubtitleDownloadErrorState):
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subtitle Download Failed'),
                                ),
                              );
                              break;
                          }
                        },
                        builder: (context, state) {
                          switch (state.runtimeType) {
                            case const (SubtitleFetchingLoadingState):
                              return const Center(
                                  child: CircularProgressIndicator());

                            case const (SubtitleFetchingSuccessfulState):
                              final successState =
                                  state as SubtitleFetchingSuccessfulState;
                              return _buildSubtitleView(
                                  successState.subtitlesDataUiModel);

                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }

  _buildSubtitleView(SubtitlesDataUiModel subtitlesDataUiModel) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          LanguageDropdown(
            onLanguageChanged: onLanguageChanged,
            initialLanguage: oldLanguage ?? 'EN',
          ),
          const Gap(8),
          if (subtitlesDataUiModel.subtitles!.isEmpty ||
              subtitlesDataUiModel.subtitles == null)
            const Text('No Subtitles Found')
          else
            Column(
              children: [
                Column(
                  children: subtitlesDataUiModel.subtitles!
                      .map(
                        (e) => ListTile(
                          title: Text(e.releaseName!),
                          subtitle: Text('Uploader: ${e.author!}'),
                          onTap: () {
                            subtitleBloc.add(
                              SubtitleDownloadEvent(
                                e.url!,
                                e.name!,
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
