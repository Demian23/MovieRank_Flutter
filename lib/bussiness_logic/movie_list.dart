import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/bussiness_logic/movie_detail.dart';
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
            index: index,
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

class FavouritesListScreen extends ConsumerWidget {
  const FavouritesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(moviesControllerProvider.notifier)
        .loadFavouritesForCurrentUserOnce();
    final movies = ref.watch(moviesControllerProvider);
    final moviesToShow =
        movies.where((element) => element.favouritesProperties != null);
    return ListView.builder(
      itemCount: moviesToShow.length,
      itemBuilder: (context, index) {
        var movie = moviesToShow.elementAt(index);
        return Column(children: [
          FavouriteListRow(
            index: index,
            genre: movie.genre.first,
            name: movie.name,
            year: movie.releaseDate,
            wholeMarks: movie.marksWholeScore,
            marksAmount: movie.marksAmount,
            purpose: movie.favouritesProperties!.purpose,
          ),
          const Divider(),
        ]);
      },
    );
  }
}

class MovieListRow extends StatelessWidget {
  final int index;
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
      required this.marksAmount,
      required this.index});

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
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MovieDetailScreen(index)));
      },
    );
  }
}

class FavouriteListRow extends StatelessWidget {
  final int index;
  final String genre;
  final String name;
  final DateTime year;
  final int wholeMarks;
  final int marksAmount;
  final FavouritesPurpose purpose;

  const FavouriteListRow(
      {super.key,
      required this.genre,
      required this.name,
      required this.year,
      required this.wholeMarks,
      required this.marksAmount,
      required this.index,
      required this.purpose});

  @override
  Widget build(BuildContext context) {
    final avgMark = marksAmount > 0 ? wholeMarks / marksAmount : 0;
    final genreShort = Genres.values
        .firstWhere((element) => element.toViewableString() == genre,
            orElse: () => Genres.other)
        .shortString();
    return ListTile(
      leading: Icon(purpose == FavouritesPurpose.favourite
          ? Icons.star
          : Icons.watch_later),
      title: Text("$name ($genreShort)"),
      subtitle: Text(year.year.toString()),
      trailing: Text(avgMark.toString()),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MovieDetailScreen(index)));
      },
    );
  }
}
