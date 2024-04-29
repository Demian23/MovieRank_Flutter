enum Role { commonUser, admin }

extension RoleAsString on Role {
  String toViewableString() {
    final temp = toString().substring(toString().indexOf('.') + 1);
    return temp[0].toUpperCase() + temp.substring(1);
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final Role role;
  final String country;
  int userScore;

  // TODO why store id with fields

  User(this.id, this.firstName, this.lastName, this.email, this.role,
      this.country,
      [this.userScore = 0]);

  User.fromMap({required String id, required Map<String, dynamic> fields})
      : this(
            id,
            fields['firstName'] ?? '',
            fields['lastName'] ?? '',
            fields['email'] ?? '',
            Role.values
                .firstWhere((e) => e.toViewableString() == "${fields['role']}"),
            fields['country'] ?? '',
            fields['userScore'] ?? 0);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.toViewableString(),
      'country': country,
      'userScore': userScore
    };
  }

  String get initials => firstName[0].toUpperCase() + lastName[0].toUpperCase();
}
