import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/features/main/ui/main_page.dart';
import 'package:subtitle_downloader/features/movies/ui/home_movies_page.dart';
import 'package:subtitle_downloader/features/profile/ui/profile_page.dart';
import 'package:subtitle_downloader/features/subtitles/ui/downloaded_subtitles_history_page.dart';
import 'package:subtitle_downloader/features/tv/ui/trending_tv_page.dart';

import '../movies/ui/movie_page.dart';
import '../profile/ui/settings_page.dart';

class AppNavigation {
  static String initR = '/movies';

  // Private Navigator Keys
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorMovies =
      GlobalKey<NavigatorState>(debugLabel: 'shellMovies');
  static final _rootNavigatorTV =
      GlobalKey<NavigatorState>(debugLabel: 'shellTV');
  static final _rootNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  // Go Router Configuration
  static final GoRouter router = GoRouter(
    initialLocation: initR,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          // Branch Movies
          StatefulShellBranch(
            navigatorKey: _rootNavigatorMovies,
            routes: [
              GoRoute(
                path: '/movies',
                name: 'Movies',
                builder: (context, state) {
                  return HomeMoviesPage(
                    key: state.pageKey,
                  );
                },
                routes: [
                  // View Movie Page
                  GoRoute(
                    path: 'view-movie/:movieId/:movieName',
                    name: 'View Movie',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => MoviePage(
                      key: state.pageKey,
                      movieId: int.parse(state.pathParameters['movieId']!),
                      movieName: state.pathParameters['movieName']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch TV
          StatefulShellBranch(
            navigatorKey: _rootNavigatorTV,
            routes: [
              GoRoute(
                path: '/tv',
                name: 'TV',
                builder: (context, state) {
                  return const TrendingTvPage();
                },
              ),
            ],
          ),
          // Branch Profile
          StatefulShellBranch(
            navigatorKey: _rootNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'Profile',
                builder: (context, state) {
                  return const ProfilePage();
                },
                routes: [
                  // View Downloaded Subtitles History
                  GoRoute(
                    path: 'downloaded-subtitles-history',
                    name: 'Downloaded Subtitles History',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const DownloadedSubtitlesHistoryPage();
                    },
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'Settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      return const SettingsPage();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
