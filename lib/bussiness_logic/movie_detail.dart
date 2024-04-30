import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/bussiness_logic/movies_controller.dart';
import 'package:movie_rank/model/movie.dart';

class MovieDetail extends ConsumerWidget {
  MovieDetail(this._movieIndex, {super.key});
  final int _movieIndex;
  final rankController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = ref.read(moviesControllerProvider).elementAt(_movieIndex);
    return Scaffold(
        appBar: AppBar(
          title: Text(movie.name),
        ),
        body: Column(
          children: [
            const Icon(Icons.image),
            Text(movie.name),
            const Text("Other fields"),
            TextField(
              controller: rankController,
              decoration: const InputDecoration(labelText: "Rank"),
            ),
            TextButton(
              child: const Text("Rank"),
              onPressed: () {},
            ),
            Text(movie.favouritesProperties?.purpose.toViewableString() ??
                "none")
          ],
        ));
  }
}
