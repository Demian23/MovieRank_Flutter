import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/bussiness_logic/user_repository.dart';
import 'package:movie_rank/model/movie.dart';
import 'package:movie_rank/providers.dart';

final moviesRepositoryProvider =
    Provider<MovieRepository>((ref) => MovieRepository(ref));

class MovieRepository {
  final Ref _ref;

  MovieRepository(this._ref);

  static const _movieCollection = "movies";
  static const _marksCollection = "marks";
  static const _marksForUserCollection = "user";
  static const _markForUserKey = "userMark";
  static const _wholeMovieScoreKey = "marksWholeScore";
  static const _movieScoresCount = "marksAmount";
  static const _favouritesCollection = "favourites";
  static const _favouritesForUserCollection = "userMovies";

  CollectionReference _movieCollectionRef() {
    return _ref
        .read(firestoreProvider)
        .collection(_movieCollection)
        .withConverter<Movie>(
            fromFirestore: (snapshot, _) =>
                Movie.fromMap(id: snapshot.id, fields: snapshot.data()!),
            toFirestore: (movie, _) => movie.toMap());
  }

  CollectionReference _favouritesCollectionRefForUser(String uid) {
    return _ref
        .read(firestoreProvider)
        .collection(_favouritesCollection)
        .doc(uid)
        .collection(_favouritesForUserCollection)
        .withConverter<FavouritesProperties>(
            fromFirestore: (snapshot, _) =>
                FavouritesProperties.fromMap(fields: snapshot.data()!),
            toFirestore: (properties, _) => properties.toMap());
  }

  DocumentReference _movieRef(String movieId) {
    return _movieCollectionRef().doc(movieId);
  }

  DocumentReference _markRef(String movieId, String userId) {
    return _ref
        .read(firestoreProvider)
        .collection(_marksCollection)
        .doc(movieId)
        .collection(_marksForUserCollection)
        .doc(userId);
  }

  Future<List<Movie>> getAllMovies() async {
    final snapshot = await _movieCollectionRef().get();
    final docs = snapshot.docs;
    final result = <Movie>[];
    if (docs.isNotEmpty) {
      for (var doc in docs) {
        result.add(doc.data() as Movie);
      }
    }
    return result;
  }

  Future<void> addMovieToUserFavourites(
      {required String movieId,
      required String userId,
      FavouritesProperties? prop}) async {
    final to = _favouritesCollectionRefForUser(userId).doc(movieId);
    final data =
        prop ?? FavouritesProperties(purpose: FavouritesPurpose.favourite);
    await to.set(data);
  }

  Future<void> deleteMovieFromUserFavourites(
      {required String movieId, required String userId}) async {
    final to = _favouritesCollectionRefForUser(userId).doc(movieId);
    await to.delete();
  }

  Future<void> updateMovieInUserFavourites(
      {required String movieId,
      required String userId,
      required FavouritesProperties properties}) async {
    final to = _favouritesCollectionRefForUser(userId).doc(movieId);
    await to.update(properties.toMap());
  }

  Future<FavouritesProperties?> getFavouritesPropertiesOfMovieInUsersFavourites(
      {required String movieId, required String userId}) async {
    final snapshot =
        await _favouritesCollectionRefForUser(userId).doc(movieId).get();
    if (snapshot.exists) {
      return snapshot.data() as FavouritesProperties;
    } else {
      return null;
    }
  }

  Future<void> addFavouriteMoviesInMovieListForUser(
      {required String uid, required List<Movie> movies}) async {
    final from = await _favouritesCollectionRefForUser(uid).get();
    final favouritesDocs = from.docs;
    for (var doc in favouritesDocs) {
      if (doc.exists) {
        final favouritesProperties = doc.data() as FavouritesProperties;
        final movieId = doc.id;
        final index = movies.indexWhere((element) => element.id == movieId);
        if (index != -1) {
          movies.elementAt(index).favouritesProperties = favouritesProperties;
        } else {
          final movieSnapshot = await _movieRef(movieId).get();
          final movie = movieSnapshot.data() as Movie;
          movie.favouritesProperties = favouritesProperties;
          movies.add(movie);
        }
      }
    }
  }

  // TODO handle errors ? exceptions?
  Future<void> updateOrCreateNewMarkForMovieByUser(
      {required String movieId,
      required String userId,
      required int newMarkValue}) async {
    final movieRef = _movieRef(movieId);
    final markRef = _markRef(movieId, userId);
    await _ref.read(firestoreProvider).runTransaction((transaction) async {
      final markSnapshot = await transaction.get(markRef);
      if (!markSnapshot.exists) {
        _ref
            .read(userRepositoryProvider)
            .incrementUserScoreInTransactionOn(userId, transaction, 1);
        transaction.set(markRef, {_markForUserKey: newMarkValue.toString()});
        transaction.update(movieRef, {
          _wholeMovieScoreKey: FieldValue.increment(newMarkValue),
          _movieScoresCount: FieldValue.increment(1)
        });
      } else {
        final oldMark = int.parse(markSnapshot.get(_markForUserKey));
        transaction.update(markRef, {_markForUserKey: newMarkValue.toString()});
        transaction.update(movieRef, {
          _wholeMovieScoreKey: FieldValue.increment(newMarkValue - oldMark)
        });
      }
    });
  }

  // TODO mark in firestore stored as String?
  Future<String> fetchMarkForMovieByUser(
      {required String movieId, required String userId}) async {
    final markSnapshot = await _markRef(movieId, userId).get();
    if (markSnapshot.exists) {
      return markSnapshot.get(_markForUserKey) as String;
    } else {
      return '';
    }
  }

  Future<List<String>> fetchImgUrlsForMovie(String movieId) async {
    List<String> result = [];
    final all =
        await _ref.read(storageProvider).ref("movies/$movieId").listAll();
    for (var item in all.items) {
      final url = await item.getDownloadURL();
      result.add(url);
    }
    return result;
  }

  Future<List<Uint8List>> fetchImagesForMovie(String movieId) async {
    List<Uint8List> result = [];
    final all =
        await _ref.read(storageProvider).ref("movies/$movieId").listAll();
    for (var item in all.items) {
      final image = await item.getData();
      if (image != null) result.add(image);
    }
    return result;
  }

  Future<Movie> getMovie(String movieId) async {
    final snapshot = await _movieRef(movieId).get();
    return snapshot.data() as Movie;
  }
}
