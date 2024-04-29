import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/bussiness_logic/movies_controller.dart';
import 'package:movie_rank/model/movie.dart';

class MovieListScreen extends ConsumerWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final movies = ref.read(moviesControllerProvider).
    final movies = ref.watch(moviesControllerProvider);
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Column(children: [
          MovieListRow(
            genre: movie.genre.first,
            name: movie.name,
            year: movie.releaseDate,
            wholeMarks: movie.marksWholeScore,
            marksAmount: movie.marksAmount,
          ),
          const Divider()
        ]);
      },
    );
  }
}

class MovieListRow extends StatelessWidget {
  final String genre;
  final String name;
  final DateTime year;
  final int wholeMarks;
  final int marksAmount;

  const MovieListRow(
      {super.key,
      required this.genre,
      required this.name,
      required this.year,
      required this.wholeMarks,
      required this.marksAmount});

  @override
  Widget build(BuildContext context) {
    final avgMark = marksAmount > 0 ? wholeMarks / marksAmount : 0;
    return ListTile(
      leading: Text(Genres.values
          .firstWhere((element) => element.toViewableString() == genre,
              orElse: () => Genres.other)
          .shortString()),
      title: Text(name),
      subtitle: Text(year.year.toString()),
      trailing: Text(avgMark.toString()),
      onTap: ,
    );
  }
}
