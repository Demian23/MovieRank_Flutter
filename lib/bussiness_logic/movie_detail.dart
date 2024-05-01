import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/bussiness_logic/movies_controller.dart';
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
  _DetaileState(this.movieIndex);

  @override
  Widget build(BuildContext context) {
    final movie = ref.read(moviesControllerProvider).elementAt(movieIndex);
    ref.read(marksControllerProvider).getMarkForMovie(movie.id).then(
          (value) => rankController.text = value,
        );
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
              onPressed: () {
                ref.read(marksControllerProvider).setMarkForMovie(movie.id,
                    int.parse(rankController.text)); // TODO add validation
              },
              
            ),
            IconButton(icon: movie.favouritesProperties.purpose == FavouritesPurpose.Favourite ? Icons.star)
            IconButton(onClick = { coroutineScope.launch { favouritesState.value = onFavouritesChange(favouritesState.value, FavouritesProperties(FavouritesPurpose.Favourite));isError.value = checkErrorState()} }) {
                Icon(
                    imageVector = if (favouritesState.value == FavouritesPurpose.Favourite) Icons.Filled.Star else Icons.Outlined.Star,
                    contentDescription = "Favourite",
                    tint = if (favouritesState.value == FavouritesPurpose.Favourite) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary,
                )
            }
            IconButton(onClick = { coroutineScope.launch { favouritesState.value = onFavouritesChange(favouritesState.value, FavouritesProperties(FavouritesPurpose.WatchLater)); isError.value = checkErrorState()} }) {
                Icon(
                    imageVector = if (favouritesState.value == FavouritesPurpose.WatchLater) Icons.Filled.DateRange else Icons.Outlined.DateRange,
                    contentDescription = "WatchLater",
                    tint = if (favouritesState.value == FavouritesPurpose.WatchLater) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary,
                )
            }
            Text(movie.favouritesProperties?.purpose.toViewableString() ??
                "none")
          ],
        ));
  }
}
