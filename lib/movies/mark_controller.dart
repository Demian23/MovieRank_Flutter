import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/aux/data_source_decision_maker.dart';
import 'package:movie_rank/movies/movies_repository.dart';
import 'package:movie_rank/user/user_controller.dart';

final marksControllerProvider =
    Provider<MarksController>((ref) => MarksController(ref));

class MarksController {
  final Map<String, int> marks = {};
  final Ref _ref;
  MarksController(this._ref);

  Future<String> getMarkForMovie(String movieId) async {
    if (marks.containsKey(movieId)) {
      return marks[movieId]!.toString();
    } else {
      final networkDataSourceSuitable = await _ref
          .read(dataSourceDecisionMakerProvider)
          .isNetworkSuitableDataSource();
      if (networkDataSourceSuitable) {
        final uid = _ref.read(userControllerProvider).firebaseUserSession!.uid;
        final mark = await _ref
            .read(moviesRepositoryProvider)
            .fetchMarkForMovieByUser(movieId: movieId, userId: uid);
        if (mark.isNotEmpty) {
          marks[movieId] = int.parse(mark);
        }
        return mark;
      } else {
        return '';
      }
    }
  }

  void setMarkForMovie(String movieId, int mark) async {
    final uid = _ref.read(userControllerProvider).firebaseUserSession!.uid;
    await _ref
        .read(moviesRepositoryProvider)
        .updateOrCreateNewMarkForMovieByUser(
            movieId: movieId, userId: uid, newMarkValue: mark);
    marks[movieId] = mark;
  }

  bool isMarkValid({required String markStringRep}) {
    final newRank = int.tryParse(markStringRep);
    return (newRank != null) && (newRank <= 100) && (newRank >= 0);
  }
}
