// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      fields[0] as String,
      fields[1] as String,
      fields[2] as DateTime,
      fields[3] as int,
      fields[4] as int,
      (fields[5] as List).cast<String>(),
      (fields[6] as List).cast<String>(),
      (fields[7] as List).cast<String>(),
      fields[8] as String,
      fields[9] as Duration,
    )..favouritesProperties = fields[10] as FavouritesProperties?;
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.releaseDate)
      ..writeByte(3)
      ..write(obj.marksAmount)
      ..writeByte(4)
      ..write(obj.marksWholeScore)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.director)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.favouritesProperties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavouritesPropertiesAdapter extends TypeAdapter<FavouritesProperties> {
  @override
  final int typeId = 2;

  @override
  FavouritesProperties read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouritesProperties(
      purpose: fields[0] as FavouritesPurpose,
    );
  }

  @override
  void write(BinaryWriter writer, FavouritesProperties obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.purpose);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritesPropertiesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavouritesPurposeAdapter extends TypeAdapter<FavouritesPurpose> {
  @override
  final int typeId = 1;

  @override
  FavouritesPurpose read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FavouritesPurpose.watchLater;
      case 1:
        return FavouritesPurpose.favourite;
      case 2:
        return FavouritesPurpose.none;
      default:
        return FavouritesPurpose.watchLater;
    }
  }

  @override
  void write(BinaryWriter writer, FavouritesPurpose obj) {
    switch (obj) {
      case FavouritesPurpose.watchLater:
        writer.writeByte(0);
        break;
      case FavouritesPurpose.favourite:
        writer.writeByte(1);
        break;
      case FavouritesPurpose.none:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouritesPurposeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
