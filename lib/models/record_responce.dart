import 'models/list_equal.dart';
import 'part.dart';

class RecordResponce {
  String? id;
  String? name;
  List<Part>? parts;

  RecordResponce({this.id, this.name, this.parts});

  @override
  String toString() => 'RecordResponce(id: $id, name: $name, parts: $parts)';

  factory RecordResponce.fromJson(Map<String, dynamic> json) => RecordResponce(
        id: json['id'] as String?,
        name: json['name'] as String?,
        parts: (json['parts'] as List<dynamic>?)
            ?.map((e) => Part.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parts': parts?.map((e) => e.toJson()).toList(),
      };

  RecordResponce copyWith({
    String? id,
    String? name,
    List<Part>? parts,
  }) {
    return RecordResponce(
      id: id ?? this.id,
      name: name ?? this.name,
      parts: parts ?? this.parts,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! RecordResponce) return false;
    return listEquals(other.parts, parts) &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ parts.hashCode;
}
