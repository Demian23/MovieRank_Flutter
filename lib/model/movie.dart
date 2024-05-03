import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final DateTime releaseDate;
  @HiveField(3)
  final int marksAmount;
  @HiveField(4)
  final int marksWholeScore;
  @HiveField(5)
  final List<String> country;
  @HiveField(6)
  final List<String> genre;
  @HiveField(7)
  final List<String> director;
  @HiveField(8)
  final String description;
  @HiveField(9)
  final Duration duration;
  @HiveField(10)
  FavouritesProperties? favouritesProperties;

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

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 3;
  @override
  Duration read(BinaryReader reader) {
    return Duration(seconds: reader.read());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.write(obj.inSeconds);
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

@HiveType(typeId: 2)
class FavouritesProperties {
  @HiveField(0)
  final FavouritesPurpose purpose;
  FavouritesProperties.fromMap({required Map<String, dynamic> fields})
      : this(
            purpose: FavouritesPurpose.values.firstWhere(
                (e) => e.toViewableString() == "${fields['purpose']}"));

  FavouritesProperties({required this.purpose});
  Map<String, dynamic> toMap() {
    return {'purpose': purpose.toViewableString()};
  }
}

@HiveType(typeId: 1)
enum FavouritesPurpose {
  @HiveField(0)
  watchLater,
  @HiveField(1)
  favourite,
  @HiveField(2)
  none,
}

extension FavouritesAsString on FavouritesPurpose {
  String toViewableString() {
    final temp = toString().substring(toString().indexOf('.') + 1);
    return temp[0].toUpperCase() + temp.substring(1);
  }
}
