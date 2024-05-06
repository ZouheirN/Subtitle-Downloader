import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'features/main/app_navigation.dart';
final logger = Logger();

// GoRouter _router = GoRouter(routes: [
//   ShellRoute(
//     routes: [
//       GoRoute(
//         path: '/trending-movies',
//         builder: (context, state) => const TrendingMoviesPage(),
//       ),
//       // GoRoute(
//       //   path: '/trending-tv',
//       //   builder: (context, state) => const TrendingMoviesPage(),
//       // ),
//     ],
//     builder: (context, state, child) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Subtitle Downloader'),
//         ),
//         body: child,
//       );
//     },
//   ),
//   GoRoute(
//     path: '/view-movie/:movieId/:movieName',
//     builder: (context, state) => MoviePage(
//       movieId: int.parse(state.pathParameters['movieId']!),
//       movieName: state.pathParameters['movieName']!,
//     ),
//   ),
// ]);

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: AppNavigation.router,
    );
  }
}
