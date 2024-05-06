import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/movies/cache/images_cache.dart';
import 'package:movie_rank/movies/movies_repository.dart';

final imagesControllerProvider =
    Provider<ImagesController>((ref) => ImagesController(ref));

class ImagesController {
  final Ref _ref;
  final Map<String, List<String>> urls = {};
  ImagesController(this._ref);

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
