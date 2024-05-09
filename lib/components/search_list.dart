import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchList extends StatelessWidget {
  final String? posterPath;
  final int id;
  final String title;
  final String releaseDate;
  final double voteAverage;
  final bool isMovie;

  const SearchList({
    super.key,
    required this.posterPath,
    required this.id,
    required this.title,
    required this.releaseDate ,
    required this.voteAverage,
    required this.isMovie,
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
        if (isMovie) {
          context.pushNamed('View Movie', pathParameters: {
            'movieId': id.toString(),
            'movieName': title,
          });
        }
      },
    );
  }
}
