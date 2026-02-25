import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:subtitle_downloader/features/subtitles/bloc/subtitle_bloc.dart';
import 'package:subtitle_downloader/features/subtitles/models/subtitles_data_ui_model.dart';

import '../../../components/language_dropdown.dart';
import '../../../hive/downloaded_subtitles_box.dart';
import '../../../hive/settings_box.dart';
import '../../movies/bloc/movies_bloc.dart';

class FileSubtitleSelectDialog extends StatefulWidget {
  final String fileName;

  const FileSubtitleSelectDialog({super.key, required this.fileName});

  @override
  State<FileSubtitleSelectDialog> createState() =>
      _FileSubtitleSelectDialogState();
}

class _FileSubtitleSelectDialogState extends State<FileSubtitleSelectDialog> {
  final movieBloc = MoviesBloc();
  final subtitleBloc = SubtitleBloc();

  String oldLanguage = SettingsBox.getDefaultLanguage();
  bool isHiSelected = false;

  void onHiChanged(bool value) {
    if (isHiSelected == value) return;
    isHiSelected = value;

    subtitleBloc.add(
      SubtitleInitialFetchFromFileName(
        widget.fileName,
        oldLanguage,
        isHiSelected,
      ),
    );
  }

  void onLanguageChanged(String language) {
    if (oldLanguage == language) return;
    oldLanguage = language;

    subtitleBloc.add(
      SubtitleInitialFetchFromFileName(
        widget.fileName,
        language,
        isHiSelected,
      ),
    );
  }

  @override
  void initState() {
    subtitleBloc.add(SubtitleInitialFetchFromFileName(
        widget.fileName, oldLanguage, isHiSelected));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubtitleBloc, SubtitleState>(
      bloc: subtitleBloc,
      buildWhen: (previous, current) => current is! SubtitleActionState,
      listenWhen: (previous, current) => current is SubtitleActionState,
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (SubtitleMovieFetchingLoadingState):
            return _buildChoicesListLoading(context);

          case const (SubtitleMovieFetchingSuccessfulState):
            final successState = state as SubtitleMovieFetchingSuccessfulState;
            return _buildChoicesList(
                successState.subtitlesDataUiModel, context);

          case const (SubtitleMovieFetchingErrorState):
            return _buildChoicesListError(context);

          default:
            return const SizedBox();
        }
      },
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
    );
  }

  Widget _buildChoicesList(
      SubtitlesDataUiModel subtitlesDataUiModel, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.75,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove,
                      color: Colors.grey[600],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Only HI Subtitles'),
                          Switch(
                            value: isHiSelected,
                            onChanged: onHiChanged,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Language'),
                          LanguageDropdown(
                            onLanguageChanged: onLanguageChanged,
                            initialLanguage: oldLanguage,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    if (subtitlesDataUiModel.subtitles == null ||
                        subtitlesDataUiModel.subtitles!.isEmpty)
                      const Text('No Subtitles Found')
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: subtitlesDataUiModel.subtitles!.length,
                          itemBuilder: (_, index) {
                            return ValueListenableBuilder(
                              valueListenable: DownloadedSubtitlesBox
                                  .downloadedSubtitlesBox
                                  .listenable(),
                              builder: (context, value, child) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: DownloadedSubtitlesBox
                                              .isSubtitleDownloaded(
                                                  subtitlesDataUiModel
                                                      .subtitles![index].url!)
                                          ? Colors.grey[100]!.withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    color: DownloadedSubtitlesBox
                                            .isSubtitleDownloaded(
                                                subtitlesDataUiModel
                                                    .subtitles![index].url!)
                                        ? Colors.grey[100]?.withOpacity(0.1)
                                        : null,
                                  ),
                                  child: ExpansionTile(
                                    title: Text(
                                      subtitlesDataUiModel
                                          .subtitles![index].releaseName!,
                                      style: TextStyle(
                                        fontWeight: DownloadedSubtitlesBox
                                                .isSubtitleDownloaded(
                                                    subtitlesDataUiModel
                                                        .subtitles![index].url!)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                        'Uploader: ${subtitlesDataUiModel.subtitles![index].author!}'),
                                    children: [
                                      if (subtitlesDataUiModel
                                                  .subtitles![index].comment !=
                                              null &&
                                          subtitlesDataUiModel
                                                  .subtitles![index].comment !=
                                              '')
                                        ListTile(
                                          title: const Text(
                                            'Comment',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(subtitlesDataUiModel
                                              .subtitles![index].comment!),
                                        ),
                                      if (subtitlesDataUiModel
                                                  .subtitles![index].releases !=
                                              null &&
                                          subtitlesDataUiModel.subtitles![index]
                                              .releases!.isNotEmpty)
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
                                              for (var release
                                                  in subtitlesDataUiModel
                                                      .subtitles![index]
                                                      .releases!)
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
                                                  subtitlesDataUiModel
                                                      .subtitles![index].url!,
                                                  subtitlesDataUiModel
                                                      .subtitles![index].name!,
                                                  subtitlesDataUiModel
                                                      .subtitles![index]
                                                      .author!,
                                                  subtitlesDataUiModel
                                                      .subtitles![index]
                                                      .releaseName!,
                                                  subtitlesDataUiModel
                                                      .results!.first.name!,
                                                  'tv',
                                                ),
                                              );
                                            },
                                            label: const Text('Download'),
                                            icon: const Icon(Icons
                                                .download_for_offline_rounded),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesListLoading(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.75,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove,
                      color: Colors.grey[600],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Only HI Subtitles'),
                          Switch(
                            value: isHiSelected,
                            onChanged: onHiChanged,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Language'),
                          LanguageDropdown(
                            onLanguageChanged: onLanguageChanged,
                            initialLanguage: oldLanguage,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesListError(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.75,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove,
                      color: Colors.grey[600],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Only HI Subtitles'),
                          Switch(
                            value: isHiSelected,
                            onChanged: onHiChanged,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Language'),
                          LanguageDropdown(
                            onLanguageChanged: onLanguageChanged,
                            initialLanguage: oldLanguage,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    const Center(
                      child: Text('Error Fetching Subtitles'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
