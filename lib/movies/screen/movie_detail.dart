import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/user/user_controller.dart';
import 'package:movie_rank/movies/cache/movies_cache.dart';
import 'package:movie_rank/movies/movies_controller.dart';
import 'package:movie_rank/movies/movies_repository.dart';
import 'package:movie_rank/model/movie.dart';

class MovieDetailScreen extends StatefulHookConsumerWidget {
  const MovieDetailScreen(this._movieIndex, {super.key});
  final int _movieIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _DetaileState(_movieIndex);
  }
}

class _DetaileState extends ConsumerState<MovieDetailScreen> {
  final int movieIndex;
  final rankController = TextEditingController();
  List<Uint8List> images = [];
  FavouritesPurpose currentPurpose = FavouritesPurpose.none;
  _DetaileState(this.movieIndex);

  @override
  Widget build(BuildContext context) {
    final movie = ref.watch(moviesControllerProvider).elementAt(movieIndex);
    setState(
      () => currentPurpose =
          movie.favouritesProperties?.purpose ?? FavouritesPurpose.none,
    );
    final avgMark =
        movie.marksAmount != 0 ? movie.marksWholeScore / movie.marksAmount : 0;

    ref.read(marksControllerProvider).getMarkForMovie(movie.id).then(
          (value) => rankController.text = value,
        );
    if (images.isEmpty) {
      ref
          .read(imgsControllerProvider)
          .getImagesForMoive(movie.id)
          .then((value) {
        setState(
          () {
            images = value;
          },
        );
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(movie.name),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Builder(builder: (context) {
              if (images.isEmpty) {
                return const Icon(
                  Icons.image,
                );
              } else {
                return CarouselSlider(
                    items: images
                        .map((item) => Center(child: Image.memory(item)))
                        .toList(),
                    options: CarouselOptions());
              }
            }),
            FractionallySizedBox(
              widthFactor: 0.8,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: Text(movie.name,
                        style: Theme.of(context).textTheme.headlineLarge),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(avgMark.toString(),
                          style: Theme.of(context).textTheme.headlineMedium))
                ],
              ),
            ),
            const Divider(),
            Text(movie.country.join(', ')),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          "Genre: ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        )),
                    Expanded(
                      flex: 7,
                      child: Text(
                        movie.genre.join(', '),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ]),
                  Row(children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          "Director: ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        )),
                    Expanded(
                      flex: 7,
                      child: Text(
                        movie.director.join(', '),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ]),
                  Row(children: [
                    Expanded(
                        flex: 5,
                        child: Text(
                          "Release Date: ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        )),
                    Expanded(
                      flex: 5,
                      child: Text(
                        "${movie.releaseDate.day}.${movie.releaseDate.month}.${movie.releaseDate.year}",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ]),
                  Row(
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                                currentPurpose == FavouritesPurpose.favourite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber),
                            onPressed: () {
                              // TODO move to some controller / view model
                              onFavouritesChange(movie.id, currentPurpose,
                                      FavouritesPurpose.favourite)
                                  .then((value) => setState(() {
                                        currentPurpose = value;
                                      }));
                            },
                          ),
                          IconButton(
                            icon: Icon(
                                currentPurpose == FavouritesPurpose.watchLater
                                    ? Icons.watch_later
                                    : Icons.watch_later_outlined,
                                color: Colors.cyan),
                            onPressed: () {
                              onFavouritesChange(movie.id, currentPurpose,
                                      FavouritesPurpose.watchLater)
                                  .then((value) => setState(() {
                                        currentPurpose = value;
                                      }));
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: TextField(
                          controller: rankController,
                          decoration: const InputDecoration(labelText: "Rank"),
                        ),
                      ),
                      TextButton(
                        child: const Text("Rank"),
                        onPressed: () {
                          final newRank = int.tryParse(rankController.text);
                          bool showError = (newRank == null) ||
                              (newRank > 100) ||
                              (newRank < 0);
                          if (!showError) {
                            ref
                                .read(marksControllerProvider)
                                .setMarkForMovie(movie.id, newRank);
                            ref
                                .read(moviesControllerProvider.notifier)
                                .updateMovie(movie.id);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "Rank should be number between 0 and 100"),
                            )); // TODO use colors from theme
                          }
                        },
                      ),
                    ],
                  ),
                  Text(
                    movie.description,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        )));
  }

  Future<FavouritesPurpose> onFavouritesChange(String movieId,
      FavouritesPurpose prevState, FavouritesPurpose currentPress) async {
    final movieRepository = ref.read(moviesRepositoryProvider);
    final uid = ref.read(authControllerProvider).firebaseUserSession!.uid;
    final cache = ref.read(moviesCacheProvider);
    if (prevState == currentPress) {
      await movieRepository.deleteMovieFromUserFavourites(
          movieId: movieId, userId: uid);
      // TODO update in movie list
      ref
          .read(moviesControllerProvider)
          .firstWhere((element) => element.id == movieId)
          .favouritesProperties = null;
      cache.delete(movieId);
      return FavouritesPurpose.none;
    } else {
      switch (prevState) {
        case FavouritesPurpose.none:
          await movieRepository.addMovieToUserFavourites(
              movieId: movieId,
              userId: uid,
              prop: FavouritesProperties(purpose: currentPress));
          break;
        case FavouritesPurpose.watchLater:
        case FavouritesPurpose.favourite:
          // TODO change update and maybe add interface from properties to purpose only
          await movieRepository.updateMovieInUserFavourites(
              movieId: movieId,
              userId: uid,
              properties: FavouritesProperties(purpose: currentPress));
          break;
      }
      final movie = ref
          .read(moviesControllerProvider)
          .firstWhere((element) => element.id == movieId)
        ..favouritesProperties = FavouritesProperties(purpose: currentPress);
      cache.put(movieId, movie);
      return currentPress;
    }
  }
}
