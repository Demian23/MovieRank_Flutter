import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/movies/image_controller.dart';
import 'package:movie_rank/movies/mark_controller.dart';
import 'package:movie_rank/movies/movies_controller.dart';
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
  bool _stateLoadedOnce = false;
  FavouritesPurpose currentPurpose = FavouritesPurpose.none;
  _DetaileState(this.movieIndex);

  @override
  Widget build(BuildContext context) {
    final movie = ref.watch(moviesControllerProvider).elementAt(movieIndex);
    final avgMark =
        movie.marksAmount != 0 ? movie.marksWholeScore / movie.marksAmount : 0;
    final marksController = ref.read(marksControllerProvider);
    final moviesController = ref.read(moviesControllerProvider.notifier);
    final imagesController = ref.read(imagesControllerProvider);
    if (!_stateLoadedOnce) {
      setState(
        () => currentPurpose =
            movie.favouritesProperties?.purpose ?? FavouritesPurpose.none,
      );

      marksController.getMarkForMovie(movie.id).then((value) {
        if (context.mounted) rankController.text = value;
      });

      imagesController.getImagesForMoive(movie.id).then((value) {
        setState(() {
          if (context.mounted) images = value;
        });
      });

      _stateLoadedOnce = true;
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
                              moviesController
                                  .onFavouritesChange(movie.id, currentPurpose,
                                      FavouritesPurpose.favourite)
                                  .then((value) => setState(() {
                                        if (context.mounted) {
                                          currentPurpose = value;
                                        }
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
                              moviesController
                                  .onFavouritesChange(movie.id, currentPurpose,
                                      FavouritesPurpose.watchLater)
                                  .then((value) => setState(() {
                                        if (context.mounted) {
                                          currentPurpose = value;
                                        }
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
                          if (marksController.isMarkValid(
                              markStringRep: rankController.text)) {
                            marksController.setMarkForMovie(
                                movie.id, int.parse(rankController.text));
                            moviesController.updateMovie(movie.id);
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
}
