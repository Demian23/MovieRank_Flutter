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

  CollectionReference _movieCollectionRef() {
    return _ref
        .read(firestoreProvider)
        .collection(_movieCollection)
        .withConverter<Movie>(
            fromFirestore: (snapshot, _) =>
                Movie.fromMap(id: snapshot.id, fields: snapshot.data()!),
            toFirestore: (movie, _) => movie.toMap());
  }

  DocumentReference _movie(String forUid) {
    return _movieCollectionRef().doc(forUid);
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
}
