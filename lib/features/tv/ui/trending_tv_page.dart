import 'package:flutter/material.dart';

class TrendingTvPage extends StatefulWidget {
  const TrendingTvPage({super.key});

  @override
  State<TrendingTvPage> createState() => _TrendingTvPageState();
}

class _TrendingTvPageState extends State<TrendingTvPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV'),
      ),
      body: const Placeholder(),
    );
  }
}