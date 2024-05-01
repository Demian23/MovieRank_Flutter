import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/bussiness_logic/movies_controller.dart';
import 'package:movie_rank/bussiness_logic/movies_repository.dart';
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
  List<String> images = [];
  FavouritesPurpose currentPurpose = FavouritesPurpose.none;
  _DetaileState(this.movieIndex);

  @override
  Widget build(BuildContext context) {
    final movie = ref.read(moviesControllerProvider).elementAt(movieIndex);
    setState(() {
      currentPurpose = ref
              .read(moviesControllerProvider)
              .elementAt(movieIndex)
              .favouritesProperties
              ?.purpose ??
          FavouritesPurpose.none;
    });

    ref.read(marksControllerProvider).getMarkForMovie(movie.id).then(
          (value) => rankController.text = value,
        );
    ref.read(imgsControllerProvider).getImgsUrls(movie.id).then((value) {
      setState(
        () {
          images = value;
        },
      );
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(movie.name),
        ),
        body: Column(
          children: [
            CarouselSlider(
                items: images
                    .map((item) => Center(
                            child: CachedNetworkImage(
                          imageUrl: item,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                        )))
                    .toList(),
                options: CarouselOptions()),
            Text(movie.name),
            const Text("Other fields"),
            TextField(
              controller: rankController,
              decoration: const InputDecoration(labelText: "Rank"),
            ),
            TextButton(
              child: const Text("Rank"),
              onPressed: () {
                ref.read(marksControllerProvider).setMarkForMovie(movie.id,
                    int.parse(rankController.text)); // TODO add validation
              },
            ),
            IconButton(
              icon: Icon(currentPurpose == FavouritesPurpose.favourite
                  ? Icons.star
                  : Icons.star_border),
              onPressed: () {
                // TODO move to some controller / view model
                onFavouritesChange(
                        movie.id, currentPurpose, FavouritesPurpose.favourite)
                    .then((value) => setState(() {
                          currentPurpose = value;
                        }));
              },
            ),
            IconButton(
              icon: Icon(currentPurpose == FavouritesPurpose.watchLater
                  ? Icons.watch_later
                  : Icons.watch_later_outlined),
              onPressed: () {
                onFavouritesChange(
                        movie.id, currentPurpose, FavouritesPurpose.watchLater)
                    .then((value) => setState(() {
                          currentPurpose = value;
                        }));
              },
            ),
            Text(movie.favouritesProperties?.purpose.toViewableString() ??
                "none")
          ],
        ));
  }

  Future<FavouritesPurpose> onFavouritesChange(String movieId,
      FavouritesPurpose prevState, FavouritesPurpose currentPress) async {
    final movieRepository = ref.read(moviesRepositoryProvider);
    final uid = ref.read(authControllerProvider).firebaseUserSession!.uid;
    if (prevState == currentPress) {
      await movieRepository.deleteMovieFromUserFavourites(
          movieId: movieId, userId: uid);
      // TODO update in movie list
      ref
          .read(moviesControllerProvider)
          .firstWhere((element) => element.id == movieId)
          .favouritesProperties = null;
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
      ref
          .read(moviesControllerProvider)
          .firstWhere((element) => element.id == movieId)
          .favouritesProperties = FavouritesProperties(purpose: currentPress);
      return currentPress;
    }
  }
}
