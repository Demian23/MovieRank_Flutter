import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/aux/data_source_decision_maker.dart';
import 'package:movie_rank/user/user_controller.dart';
import 'package:movie_rank/movies/cache/images_cache.dart';
import 'package:movie_rank/movies/cache/movies_cache.dart';
import 'package:movie_rank/movies/movies_repository.dart';
import 'package:movie_rank/model/movie.dart';

final moviesControllerProvider =
    StateNotifierProvider<MoviesController, List<Movie>>(
  (ref) => MoviesController(ref),
);

class MoviesController extends StateNotifier<List<Movie>> {
  final Ref _ref;
  bool _favouritesLoaded = false;
  MoviesController(this._ref) : super([]) {
    final authState = _ref.watch(authStateChangesProvider);
    authState.when(
      data: (user) async {
        if (user != null) {
          await _openCaches();
          final networkDataSourceSuitable = await _ref
              .read(dataSourceDecisionMakerProvider)
              .isNetworkSuitableDataSource();
          if (networkDataSourceSuitable) {
            state = await _ref.read(moviesRepositoryProvider).getAllMovies();
          } else {
            state = _ref.read(moviesCacheProvider).getAll().values.toList();
          }
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }

  Future<void> _openCaches() async {
    await _ref.read(moviesCacheProvider).openCache();
    await _ref.read(imagesCacheProvider).openCache();
  }

  void clearCaches() async {
    _ref.read(moviesCacheProvider).clear();
    _ref.read(moviesCacheProvider).closeCache();
    _ref.read(imagesCacheProvider).clear();
    _ref.read(imagesCacheProvider).closeCache();
  }

  void loadFavouritesForCurrentUserOnce() async {
    if (!_favouritesLoaded) {
      final networkDataSourceSuitable = await _ref
          .read(dataSourceDecisionMakerProvider)
          .isNetworkSuitableDataSource();
      if (networkDataSourceSuitable) {
        final uid = _ref.read(userControllerProvider).firebaseUserSession!.uid;
        await _ref
            .read(moviesRepositoryProvider)
            .addFavouriteMoviesInMovieListForUser(uid: uid, movies: state);
        final cache = _ref.read(moviesCacheProvider);
        final favourites =
            state.where((element) => element.favouritesProperties != null);
        cache.clear();
        for (var movie in favourites) {
          cache.put(movie.id, movie);
        }
        _favouritesLoaded = true;
        _ref.notifyListeners(); // TODO change to immutable entities?
      }
    }
  }

  Future<FavouritesPurpose> loadFavouritePurposeForMovie(String movieId) async {
    final movieIndex = state.indexWhere((element) => element.id == movieId);
    if (movieIndex != -1) {
      final uid = _ref.read(userControllerProvider).firebaseUserSession!.uid;
      final result = await _ref
          .read(moviesRepositoryProvider)
          .getFavouritesPropertiesOfMovieInUsersFavourites(
              movieId: movieId, userId: uid);
      state[movieIndex].favouritesProperties = result;
      return result?.purpose ?? FavouritesPurpose.none;
    } else {
      return FavouritesPurpose.none;
    }
  }

  void updateMovie(String movieId) async {
    final newMovie =
        await _ref.read(moviesRepositoryProvider).getMovie(movieId);
    final index = state.indexWhere((element) => element.id == movieId);
    if (index == -1) {
      state.add(newMovie);
    } else {
      final favourites = state[index].favouritesProperties;
      newMovie.favouritesProperties = favourites;
      state[index] = newMovie;
    }
  }

  Future<FavouritesPurpose> onFavouritesChange(String movieId,
      FavouritesPurpose prevState, FavouritesPurpose currentPress) async {
    final movieRepository = _ref.read(moviesRepositoryProvider);
    final uid = _ref.read(userControllerProvider).firebaseUserSession!.uid;
    final cache = _ref.read(moviesCacheProvider);
    if (prevState == currentPress) {
      await movieRepository.deleteMovieFromUserFavourites(
          movieId: movieId, userId: uid);
      state
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
      final movie = state.firstWhere((element) => element.id == movieId)
        ..favouritesProperties = FavouritesProperties(purpose: currentPress);
      cache.put(movieId, movie);
      return currentPress;
    }
  }
}
