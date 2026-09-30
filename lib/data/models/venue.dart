import 'enums.dart';

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.surface,
    required this.parking,
  });

  final String id;
  final String name;
  final City city;
  final String address;
  final String surface;
  final String parking;
}
