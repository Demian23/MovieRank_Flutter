import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final imagesCacheProvider = Provider<ImagesCache>((ref) => ImagesCache());

class ImagesCache {
  static const _boxName = "images";
  late Box _imagesBox;

  Future<void> openCache() async {
    _imagesBox = await Hive.openBox<List>(_boxName);
  }

  void closeCache() async {
    await _imagesBox.close();
  }

  void put(String key, List<Uint8List> imageBytes) {
    _imagesBox.put(key, imageBytes);
  }

  List<Uint8List> get(String key) {
    final List<dynamic> list = _imagesBox.get(key);
    return list.cast<Uint8List>();
  }

  void delete(String key) {
    _imagesBox.delete(key);
  }

  void clear() {
    _imagesBox.clear();
  }

  bool hasKey(String key) {
    return _imagesBox.containsKey(key);
  }
}
