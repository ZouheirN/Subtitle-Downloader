import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:subtitle_downloader/features/movies/ui/movie_page.dart';
import 'package:subtitle_downloader/main.dart';

class MovieSearchList extends StatelessWidget {
  final String? posterPath;
  final int id;
  final String title;
  final String releaseDate;
  final double voteAverage;

  const MovieSearchList({
    super.key,
    required this.posterPath,
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.voteAverage,
  });

  @override
  Widget build(BuildContext context) {
    // extract year from release date
    final year = releaseDate.split('-').first;

    return ListTile(
      leading: posterPath == null
          ? null
          : CachedNetworkImage(
              imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
      title: Text(title),
      subtitle: Text("$year • ${voteAverage.toStringAsFixed(1)}"),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return MoviePage(movieId: id, movieName: title);
            },
          ),
        );
      },
    );
  }
}