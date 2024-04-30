import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/model/movie.dart';
import 'package:movie_rank/providers.dart';

final moviesRepositoryProvider =
    Provider<MovieRepository>((ref) => MovieRepository(ref));

class MovieRepository {
  final Ref _ref;

  MovieRepository(this._ref);

  static const _movieCollection = "movies";
  static const _movieMarkComponents = ["marksWholeScore", "marksAmount"];
  static const _marksCollection = "marks";
  static const _marksForUserCollection = "user";
  static const _markForUserKey = "userMark";
  static const _userScoreKey = "marksWholeScore";
  static const _favouritesCollection = "favourites";
  static const _favouritesForUserCollection = "userMovies";
  static const _favouritesForUserMoviePurposeKey = "purpose";

  CollectionReference _movieCollectionRef() {
    return _ref
        .read(firestoreProvider)
        .collection(_movieCollection)
        .withConverter<Movie>(
            fromFirestore: (snapshot, _) =>
                Movie.fromMap(id: snapshot.id, fields: snapshot.data()!),
            toFirestore: (movie, _) => movie.toMap());
  }

  DocumentReference _movieRef(String movieId) {
    return _movieCollectionRef().doc(movieId);
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

  Future<void> updateOrCreateNewMarkForMovieByUser(
      {required String movieId,
      required String userId,
      required int newMarkValue}) async {
    final movieRef = _movieRef(movieId);
    final makrRef = null;
  }
}
