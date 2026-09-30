/// A lightweight reference to a person, used in lists, teams and tables.
class Person {
  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String firstName;
  final String lastName;

  /// "Sam K."
  String get shortName =>
      lastName.isEmpty ? firstName : '$firstName ${lastName[0]}.';

  /// "SK"
  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    return '$first$last'.toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is Person && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
