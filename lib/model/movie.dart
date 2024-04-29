import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String name;
  final DateTime releaseDate;
  final int marksAmount;
  final int marksWholeScore;
  final List<String> country;
  final List<String> genre;
  final List<String> director;
  final String description;
  final Duration duration;

  Movie(
      this.id,
      this.name,
      this.releaseDate,
      this.marksAmount,
      this.marksWholeScore,
      this.country,
      this.genre,
      this.director,
      this.description,
      this.duration);

  Movie.fromMap({required String id, required Map<String, dynamic> fields})
      : this(
            id,
            fields['name'] ?? '',
            (fields['releaseDate'] ?? 0 as Timestamp).toDate(),
            fields['marksAmount'] ?? 0,
            fields['marksWholeScore'] ?? 0,
            List<String>.from(fields['country'] ?? []),
            List<String>.from(fields['genre'] ?? []),
            List<String>.from(fields['director'] ?? []),
            fields['description'] ?? '',
            Duration(seconds: (fields['duration'] ?? 0.0).round()));
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'releaseDate': releaseDate,
      'marksAmount': marksAmount,
      'marksWholeScore': marksWholeScore,
      'country': country,
      'genre': genre,
      'director': director,
      'description': description,
      'duration': duration.inSeconds
    };
  }
}

enum Genres {
  action,
  adventure,
  biography,
  comedy,
  crime,
  drama,
  documentary,
  detective,
  fantasy,
  history,
  horror,
  mistery,
  musical,
  noir,
  romance,
  sciFi,
  sport,
  thriller,
  war,
  western,
  other
}

extension GenreAsString on Genres {
  String toViewableString() {
    final temp = toString().substring(toString().indexOf('.') + 1);
    return temp[0].toUpperCase() + temp.substring(1);
  }

  String shortString() {
    switch (this) {
      case Genres.action:
        return "Act";
      case Genres.adventure:
        return "Adv";
      case Genres.biography:
        return "Bio";
      case Genres.comedy:
        return "Com";
      case Genres.crime:
        return "Cr";
      case Genres.drama:
        return "Dr";
      case Genres.documentary:
        return "Doc";
      case Genres.detective:
        return "Det";
      case Genres.fantasy:
        return "F";
      case Genres.history:
        return "H";
      case Genres.horror:
        return "Hor";
      case Genres.mistery:
        return "Mis";
      case Genres.musical:
        return "Mus";
      case Genres.noir:
        return "N";
      case Genres.romance:
        return "R";
      case Genres.sciFi:
        return "SF";
      case Genres.sport:
        return "S";
      case Genres.thriller:
        return "Th";
      case Genres.war:
        return "War";
      case Genres.western:
        return "Wes";
      case Genres.other:
        return "Oth";
      default:
        return "";
    }
  }
}

class FavouritesProperties {
  final FavouritesPurpose purpose;

  FavouritesProperties({required this.purpose});
}

enum FavouritesPurpose {
  watchLater,
  vavourite,
  none,
}

extension FavouritesAsString on FavouritesPurpose {
  String toViewableString() {
    final temp = toString().substring(toString().indexOf('.') + 1);
    return temp[0].toUpperCase() + temp.substring(1);
  }
}
