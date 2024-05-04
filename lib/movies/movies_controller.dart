import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/user/user_controller.dart';
import 'package:movie_rank/movies/cache/images_cache.dart';
import 'package:movie_rank/movies/cache/movies_cache.dart';
import 'package:movie_rank/movies/movies_repository.dart';
import 'package:movie_rank/model/movie.dart';

final moviesControllerProvider =
    StateNotifierProvider<MoviesController, List<Movie>>(
  (ref) => MoviesController(ref),
);

final marksControllerProvider =
    Provider<MarksController>((ref) => MarksController(ref));
final imgsControllerProvider =
    Provider<ImagesUrlsController>((ref) => ImagesUrlsController(ref));

class MoviesController extends StateNotifier<List<Movie>> {
  final Ref _ref;
  bool _favouritesLoaded = false;
  MoviesController(this._ref) : super([]) {
    final authState = _ref.watch(authStateChangesProvider);
    authState.when(
      data: (user) async {
        if (user != null) {
          await _openCaches();
          final connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.wifi) ||
              connectivityResult.contains(ConnectivityResult.mobile) ||
              connectivityResult.contains(ConnectivityResult.ethernet)) {
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
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
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
      final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
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
}

class MarksController {
  final Map<String, int> marks = {};
  final Ref _ref;
  MarksController(this._ref);

  Future<String> getMarkForMovie(String movieId) async {
    if (marks.containsKey(movieId)) {
      return marks[movieId]!.toString();
    } else {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
        final mark = await _ref
            .read(moviesRepositoryProvider)
            .fetchMarkForMovieByUser(movieId: movieId, userId: uid);
        if (mark.isNotEmpty) {
          marks[movieId] = int.parse(mark);
        }
        return mark;
      } else {
        return '';
      }
    }
  }

  void setMarkForMovie(String movieId, int mark) async {
    final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
    await _ref
        .read(moviesRepositoryProvider)
        .updateOrCreateNewMarkForMovieByUser(
            movieId: movieId, userId: uid, newMarkValue: mark);
    marks[movieId] = mark;
  }
}

class ImagesUrlsController {
  final Ref _ref;
  final Map<String, List<String>> urls = {};
  ImagesUrlsController(this._ref);

  Future<List<String>> getImgsUrls(String movieId) async {
    if (!urls.containsKey(movieId)) {
      final urlsForMovie = await _ref
          .read(moviesRepositoryProvider)
          .fetchImgUrlsForMovie(movieId);
      urls[movieId] = urlsForMovie;
    }
    return urls[movieId]!;
  }

  Future<List<Uint8List>> getImagesForMoive(String movieId) async {
    final imageCache = _ref.read(imagesCacheProvider);
    if (imageCache.hasKey(movieId)) {
      return imageCache.get(movieId);
    } else {
      final images = await _ref
          .read(moviesRepositoryProvider)
          .fetchImagesForMovie(movieId);
      if (images.isNotEmpty) {
        imageCache.put(movieId, images);
      }
      return images;
    }
  }
}
