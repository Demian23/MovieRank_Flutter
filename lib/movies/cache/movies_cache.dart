import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/model/movie.dart';
import 'package:movie_rank/movies/cache/cache.dart';

final moviesCacheProvider = Provider<MoviesCache>((ref) => MoviesCache());

class MoviesCache extends Cache<Movie, String> {
  @override
  String get boxName => "movies";
}
