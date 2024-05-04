import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
  bool showMorePressed = false;

  @override
  void initState() {
    movieBloc.add(MovieViewInitialFetchEvent(widget.movieId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const CircleAvatar(child: Icon(Icons.arrow_back_rounded)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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

    return Stack(
      children: [
        CachedNetworkImage(
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movieDataUiModel.title ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // IconButton(
                    //     onPressed: () {},
                    //     icon: const Icon(Icons.download_for_offline_rounded))
                  ],
                ),
                const Gap(8),
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
                    child: Text(movieDataUiModel.overview ?? 'No Overview'),
                  ),
                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    // Lis
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
