import 'location.dart';
import 'models/list_equal.dart';

class Part {
  String? id;
  List<Location>? locations;

  Part({this.id, this.locations});

  @override
  String toString() => 'Part(id: $id, locations: $locations)';

  factory Part.fromJson(Map<String, dynamic> json) => Part(
        id: json['id'] as String?,
        locations: (json['locations'] as List<dynamic>?)
            ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'locations': locations?.map((e) => e.toJson()).toList(),
      };

  Part copyWith({
    String? id,
    List<Location>? locations,
  }) {
    return Part(
      id: id ?? this.id,
      locations: locations ?? this.locations,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! Part) return false;
    return listEquals(other.locations, locations) && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ locations.hashCode;
}
