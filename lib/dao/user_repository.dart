import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/model/user.dart';
import 'package:movie_rank/providers.dart';

final userDaoProvider = Provider<UserRepository>((ref) => UserRepository(ref));

class UserRepository {
  final Ref _ref;

  static const _userCollection = "users";
  static const _userScoreKey = "userScore";
  static const _favouritesCollection = "favourites";
  static const _favouritesForUserCollection = "userMovies";
  static const _favouritesPurposeKey = "purpose";

  UserRepository(this._ref);

  CollectionReference _userCollectionRef() {
    return _ref
        .read(firestoreProvider)
        .collection(_userCollection)
        .withConverter<User>(
            fromFirestore: (snapshot, _) =>
                User.fromMap(id: snapshot.id, fields: snapshot.data()!),
            toFirestore: (user, _) => user.toMap());
  }

  DocumentReference _user(String uid) {
    return _userCollectionRef().doc(uid);
  }

  CollectionReference _favouriteMoviesForUser(String uid) {
    return _ref
        .read(firestoreProvider)
        .collection(_favouritesCollection)
        .doc(uid)
        .collection(_favouritesForUserCollection);
  }

  DocumentReference _favouritesForUser(String uid) {
    return _ref
        .read(firestoreProvider)
        .collection(_favouritesCollection)
        .doc(uid);
  }

  Future<User> fetchUser({required String uid}) async {
    final snapshot = await _user(uid).get();
    if (snapshot.exists) {
      return snapshot.data() as User;
    } else {
      throw Exception("No such user");
    }
  }

  Future<void> createNewUser(User user) async {
    await _user(user.id).set(user);
  }

  Future<void> setNewUserScore(
      {required String forUid, required int score}) async {
    await _user(forUid).update({_userScoreKey: score});
  }

  Future<void> updateUserScore(
      {required String forUid, required int on}) async {
    await _user(forUid).update({_userScoreKey: FieldValue.increment(on)});
  }

  Future<void> deleteData({required String forUid}) async {
    final batch = _ref.read(firestoreProvider).batch();
    batch.delete(_user(forUid));
    batch.delete(_favouritesForUser(forUid));
    // TODO delete marks too or make it as clound func
    await batch.commit();
  }
}
