import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/components/season_dropdown.dart';
import 'package:subtitle_downloader/features/tv/bloc/tv_bloc.dart';
import 'package:subtitle_downloader/features/tv/models/tv_data_ui_model.dart';

import '../../../components/language_dropdown.dart';
import '../../../hive/downloaded_subtitles_box.dart';
import '../../../hive/settings_box.dart';
import '../../subtitles/bloc/subtitle_bloc.dart';
import '../../subtitles/models/subtitles_data_ui_model.dart';

class TvPage extends StatefulWidget {
  final int tvId;
  final String tvName;

  const TvPage({super.key, required this.tvId, required this.tvName});

  @override
  State<TvPage> createState() => _TvPageState();
}

class _TvPageState extends State<TvPage> {
  final TvBloc tvBloc = TvBloc();
  final SubtitleBloc subtitleBloc = SubtitleBloc();
  bool showMorePressed = false;
  String oldLanguage = SettingsBox.getDefaultLanguage();
  int oldSeason = 1;
  int oldEpisode = 1;

  ValueNotifier query = ValueNotifier('');

  void onLanguageChanged(String language) {
    if (oldLanguage == language) return;
    oldLanguage = language;

    subtitleBloc.add(
      SubtitleTvInitialFetchEvent(
        widget.tvId.toString(),
        oldSeason,
        oldEpisode,
        language,
      ),
    );
  }

  void onSeasonChanged(int season, int episode) {
    if (oldSeason == season && oldEpisode == episode) return;

    oldSeason = season;
    oldEpisode = episode;

    subtitleBloc.add(
      SubtitleTvInitialFetchEvent(
        widget.tvId.toString(),
        oldSeason,
        oldEpisode,
        oldLanguage,
      ),
    );
  }

  @override
  void initState() {
    tvBloc.add(TvViewInitialFetchEvent(widget.tvId.toString()));
    subtitleBloc.add(
      SubtitleTvInitialFetchEvent(
        widget.tvId.toString(),
        oldSeason,
        oldEpisode,
        oldLanguage,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TvBloc, TvState>(
        bloc: tvBloc,
        buildWhen: (previous, current) => current is! TvActionState,
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (TvViewFetchingLoadingState):
              return const Center(child: CircularProgressIndicator());

            case const (TvViewFetchingSuccessfulState):
              final successState = state as TvViewFetchingSuccessfulState;
              return _buildTvView(successState.tvDataUiModel);

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildTvView(TvDataUiModel tvDataUiModel) {
    final datePared =
        DateTime.tryParse(tvDataUiModel.firstAirDate?.toIso8601String() ?? '');

    final genres = tvDataUiModel.genres?.map(
      (e) {
        return e.name;
      },
    ).join(', ');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            // centerTitle: true,
            title: Text(
              tvDataUiModel.name ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            background: Image.network(
              'https://image.tmdb.org/t/p/w500${tvDataUiModel.backdropPath}',
              fit: BoxFit.cover,
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
                            ? '${datePared.year} • $genres'
                            : 'No Release Date',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      _buildRatingView(tvDataUiModel),
                      const Gap(8),
                      if (!showMorePressed)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showMorePressed = true;
                            });
                          },
                          child: Text(
                            tvDataUiModel.overview ?? 'No Overview',
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
                          child: Text(tvDataUiModel.overview ?? 'No Overview'),
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
                                  content: Text(
                                      'Write Permissions Were Not Granted'),
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
                            case const (SubtitleTvFetchingLoadingState):
                              return const Center(
                                  child: CircularProgressIndicator());

                            case const (SubtitleTvFetchingSuccessfulState):
                              final successState =
                                  state as SubtitleTvFetchingSuccessfulState;
                              return _buildSubtitleView(
                                  successState.subtitlesDataUiModel,
                                  tvDataUiModel);

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

  Text _buildRatingView(TvDataUiModel tvDataUiModel) {
    final rating = tvDataUiModel.voteAverage;

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

  Widget _buildSubtitleView(
      SubtitlesDataUiModel subtitlesDataUiModel, TvDataUiModel tvDataUiModel) {
    final subtitles = subtitlesDataUiModel.subtitles;

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
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
          SeasonDropdown(
            initialSeason: oldSeason,
            initialEpisode: oldEpisode,
            seasons: tvDataUiModel.seasons ?? [],
            onSeasonChanged: onSeasonChanged,
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
                              child: ListTile(
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
                                onTap: () {
                                  subtitleBloc.add(
                                    SubtitleDownloadEvent(
                                      e.url!,
                                      e.name!,
                                      e.author!,
                                      e.releaseName!,
                                      subtitlesDataUiModel.results!.first.name!,
                                      'tv',
                                    ),
                                  );
                                },
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