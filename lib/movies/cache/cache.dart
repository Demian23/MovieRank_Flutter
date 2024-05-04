import 'package:hive_flutter/hive_flutter.dart';

abstract class Cache<T, K> {
  late Box box;
  String get boxName;

  Future<void> openCache() async {
    box = await Hive.openBox<T>(boxName);
  }

  void closeCache() async {
    box.close();
  }

  void clear() {
    box.clear();
  }

  Future<void> put(K key, T object) async {
    await box.put(key, object);
  }

  Future<void> delete(K key) async {
    await box.delete(key);
  }

  T get(K key) {
    return box.get(key) as T;
  }

  Map<K, T> getAll() {
    return box.toMap().cast<K, T>();
  }

  bool hasKey(K key) {
    return box.containsKey(key);
  }
}
