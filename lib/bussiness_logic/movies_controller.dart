import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/bussiness_logic/movies_repository.dart';
import 'package:movie_rank/model/movie.dart';

final moviesControllerProvider =
    StateNotifierProvider<MoviesController, List<Movie>>(
  (ref) => MoviesController(ref),
);

class MoviesController extends StateNotifier<List<Movie>> {
  final Ref _ref;
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
}
