import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/bussiness_logic/movies_repository.dart';
import 'package:movie_rank/dao/user_repository.dart';
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
          state = await _ref.read(moviesRepositoryProvider).getAllMovies();
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }

  void loadFavouritesForCurrentUserOnce() async {
    if (!_favouritesLoaded) {
      final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
      await _ref
          .read(moviesRepositoryProvider)
          .addFavouriteMoviesInMovieListForUser(uid: uid, movies: state);
      _favouritesLoaded = true;
      _ref.notifyListeners(); // TODO change to immutable entities?
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
}

class MarksController {
  final Map<String, int> marks = {};
  final Ref _ref;
  MarksController(this._ref);

  Future<String> getMarkForMovie(String movieId) async {
    if (marks.containsKey(movieId)) {
      return marks[movieId]!.toString();
    } else {
      final uid = _ref.read(authControllerProvider).firebaseUserSession!.uid;
      final mark = await _ref
          .read(moviesRepositoryProvider)
          .fetchMarkForMovieByUser(movieId: movieId, userId: uid);
      if (mark.isNotEmpty) {
        marks[movieId] = int.parse(mark);
      }
      return mark;
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
}
