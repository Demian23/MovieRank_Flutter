import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:movie_rank/model/movie.dart';

final moviesCacheProvider = Provider<MoviesCache>((ref) => MoviesCache());

class MoviesCache {
  static const String _boxName = "movies";
  late final Box _moviesBox;

  Future<void> openCache() async {
    _moviesBox = await Hive.openBox<Movie>(_boxName);
  }

  void closeCache() async {
    await _moviesBox.close();
  }

  void put(String key, Movie movie) async {
    if (!_moviesBox.isOpen) {
      await openCache();
    }
    _moviesBox.put(key, movie);
  }

  Movie get(String key) {
    return _moviesBox.get(key) as Movie;
  }

  List<Movie> getAll() {
    return _moviesBox.values.toList().cast<Movie>();
  }

  void delete(String key) {
    _moviesBox.delete(key);
  }

  void clear() {
    _moviesBox.clear();
  }
}
