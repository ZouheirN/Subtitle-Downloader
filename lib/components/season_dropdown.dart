import 'package:flutter/material.dart';
import 'package:subtitle_downloader/features/tv/models/tv_data_ui_model.dart';

class SeasonDropdown extends StatelessWidget {
  final void Function(int, int)? onSeasonChanged;
  final List<Season> seasons;
  final int initialSeason;
  final int initialEpisode;

  const SeasonDropdown({
    super.key,
    required this.onSeasonChanged,
    required this.initialSeason,
    required this.initialEpisode,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    Map<int, int> seasonEpisodeCount = {};

    for (var season in seasons) {
      seasonEpisodeCount[season.seasonNumber ?? 0] = season.episodeCount ?? 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropdownButton<int>(
          value: initialSeason,
          onChanged: (int? newValue) {
            onSeasonChanged!(newValue!, 1);
          },
          items: seasonEpisodeCount.keys
              .map((int seasonNumber) => DropdownMenuItem<int>(
                    value: seasonNumber,
                    child: Text('Season $seasonNumber'),
                  ))
              .toList(),
        ),
        DropdownButton<int>(
          value: initialEpisode,
          onChanged: (int? newValue) {
            onSeasonChanged!(initialSeason, newValue!);
          },
          items: List.generate(
            seasonEpisodeCount[initialSeason] ?? 0,
            (index) => index + 1,
          )
              .map((int episodeNumber) => DropdownMenuItem<int>(
                    value: episodeNumber,
                    child: Text('Episode $episodeNumber'),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
