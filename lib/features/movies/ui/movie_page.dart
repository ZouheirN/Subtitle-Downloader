import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:readmore/readmore.dart';
import 'package:subtitle_downloader/components/language_dropdown.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';
import 'package:subtitle_downloader/hive/downloaded_subtitles_box.dart';
import 'package:subtitle_downloader/hive/settings_box.dart';

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
  String oldLanguage = SettingsBox.getDefaultLanguage();
  bool isHiSelected = false;

  ValueNotifier query = ValueNotifier('');

  void onHiChanged(bool value) {
    if (isHiSelected == value) return;
    isHiSelected = value;

    subtitleBloc.add(
      SubtitleMovieInitialFetchEvent(
        widget.movieId.toString(),
        oldLanguage,
        isHiSelected,
      ),
    );
  }

  void onLanguageChanged(String language) {
    if (oldLanguage == language) return;
    oldLanguage = language;

    subtitleBloc.add(
      SubtitleMovieInitialFetchEvent(
        widget.movieId.toString(),
        language,
        isHiSelected,
      ),
    );
  }

  @override
  void initState() {
    movieBloc.add(MovieViewInitialFetchEvent(widget.movieId));
    subtitleBloc.add(
      SubtitleMovieInitialFetchEvent(
        widget.movieId.toString(),
        oldLanguage,
        isHiSelected,
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

    return DraggableHome(
      title: Text(
        movieDataUiModel.title ?? 'No Title',
      ),
      alwaysShowLeadingAndAction: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      headerBottomBar: Text(
        movieDataUiModel.title ?? 'No Title',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
      headerWidget: CachedNetworkImage(
        imageUrl:
            'https://image.tmdb.org/t/p/w1280${movieDataUiModel.backdropPath}',
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
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${datePared?.year} • $genres • $runtime',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                _buildRatingView(movieDataUiModel),
                const Gap(8),
                ReadMoreText(
                  movieDataUiModel.overview ?? 'No Overview',
                  trimMode: TrimMode.Line,
                  trimLines: 3,
                  trimCollapsedText: '\nShow more',
                  trimExpandedText: '\nShow less',
                  textAlign: TextAlign.justify,
                  moreStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  lessStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
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
                      case const (SubtitleDownloadPermissionNotGrantedState):
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Write Permissions Were Not Granted'),
                          ),
                        );
                        break;
                      case const (SubtitleDownloadStartedState):
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading Subtitle...'),
                          ),
                        );
                        break;
                      case const (SubtitleDownloadSuccessState):
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subtitle Downloaded'),
                          ),
                        );
                        break;
                      case const (SubtitleDownloadErrorState):
                        ScaffoldMessenger.of(context).clearSnackBars();
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
                      case const (SubtitleMovieFetchingLoadingState):
                        return const Center(child: CircularProgressIndicator());

                      case const (SubtitleMovieFetchingSuccessfulState):
                        final successState =
                            state as SubtitleMovieFetchingSuccessfulState;
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
        ),
      ],
    );
  }

  Text _buildRatingView(MovieDataUiModel movieDataUiModel) {
    final rating = movieDataUiModel.voteAverage;

    return Text(
      rating?.toStringAsFixed(1) ?? 'No Rating',
      style: TextStyle(
        fontSize: 16,
        color: rating! > 7
            ? Colors.green
            : rating > 5
                ? Colors.amber
                : Colors.red,
      ),
    );
  }

  Widget _buildSubtitleView(SubtitlesDataUiModel subtitlesDataUiModel) {
    final subtitles = subtitlesDataUiModel.subtitles;

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Only HI Subtitles'),
              Switch(
                value: isHiSelected,
                onChanged: onHiChanged,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Language'),
              LanguageDropdown(
                onLanguageChanged: onLanguageChanged,
                initialLanguage: oldLanguage,
              ),
            ],
          ),
          const Gap(8),
          TextField(
            onChanged: (newQuery) {
              setState(() {
                query.value = newQuery;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search Subtitles',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const Gap(8),
          if (subtitles == null || subtitles.isEmpty)
            const Text('No Subtitles Found')
          else
            ValueListenableBuilder(
              valueListenable: query,
              builder: (context, value, child) {
                // filter subtitles based on query based on release name and author
                final filteredSubtitles = subtitles.where((element) {
                  return element.releaseName!
                          .toLowerCase()
                          .contains(value.toString().toLowerCase()) ||
                      element.author!
                          .toLowerCase()
                          .contains(value.toString().toLowerCase());
                }).toList();

                return Column(
                  children: filteredSubtitles
                      .map(
                        (e) => ValueListenableBuilder(
                          valueListenable: DownloadedSubtitlesBox
                              .downloadedSubtitlesBox
                              .listenable(),
                          builder: (context, value, child) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DownloadedSubtitlesBox
                                          .isSubtitleDownloaded(e.url!)
                                      ? Colors.grey[100]!.withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                color:
                                    DownloadedSubtitlesBox.isSubtitleDownloaded(
                                            e.url!)
                                        ? Colors.grey[100]?.withOpacity(0.1)
                                        : null,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  e.releaseName!,
                                  style: TextStyle(
                                    fontWeight: DownloadedSubtitlesBox
                                            .isSubtitleDownloaded(e.url!)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text('Uploader: ${e.author!}'),
                                children: [
                                  if (e.comment != null && e.comment != '')
                                    ListTile(
                                      title: const Text(
                                        'Comment',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(e.comment!),
                                    ),
                                  if (e.releases != null &&
                                      e.releases!.isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        'Releases',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (var release in e.releases!)
                                            Text(release),
                                        ],
                                      ),
                                    ),
                                  OverflowBar(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          subtitleBloc.add(
                                            SubtitleDownloadEvent(
                                              e.url!,
                                              e.name!,
                                              e.author!,
                                              e.releaseName!,
                                              subtitlesDataUiModel
                                                  .results!.first.name!,
                                              'movie',
                                            ),
                                          );
                                        },
                                        label: const Text('Download'),
                                        icon: const Icon(
                                            Icons.download_for_offline_rounded),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
