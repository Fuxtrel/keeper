import 'download_dir.dart';
import 'models/list_equal.dart';

class DownloadResponse {
  String? id;
  String? name;
  List<DownloadDir>? downloadDirs;

  DownloadResponse({this.id, this.name, this.downloadDirs});

  @override
  String toString() {
    return 'DownloadResponse(id: $id, name: $name, downloadDirs: $downloadDirs)';
  }

  factory DownloadResponse.fromJson(Map<String, dynamic> json) =>
      DownloadResponse(
        id: json['id'] as String?,
        name: json['name'] as String?,
        downloadDirs: (json['downloadDirs'] as List<dynamic>?)
            ?.map((e) => DownloadDir.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'downloadDirs': downloadDirs?.map((e) => e.toJson()).toList(),
      };

  DownloadResponse copyWith({
    String? id,
    String? name,
    List<DownloadDir>? downloadDirs,
  }) {
    return DownloadResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      downloadDirs: downloadDirs ?? this.downloadDirs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DownloadResponse &&
        listEquals(other.downloadDirs, downloadDirs) &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ downloadDirs.hashCode;
}
