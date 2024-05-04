import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/movies/cache/cache.dart';

final imagesCacheProvider = Provider<ImagesCache>((ref) => ImagesCache());

class ImagesCache extends Cache<List, String> {
  @override
  String get boxName => "images";

  @override
  List<Uint8List> get(String key) {
    final List<dynamic> list = box.get(key);
    return list.cast<Uint8List>();
  }
}
