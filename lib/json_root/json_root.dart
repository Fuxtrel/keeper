/// name : "root"
/// size : 74
/// folders : [{"size":74,"isFavorite":false,"_id":"614d95d623cca00e93ba504f","name":"f1","id":"614d95d623cca00e93ba504f"},{"size":0,"isFavorite":false,"_id":"615305568896106c23c16b5c","name":"Media","id":"615305568896106c23c16b5c"},{"size":0,"isFavorite":false,"_id":"615305568896106c23c16b5e","name":"Files","id":"615305568896106c23c16b5e"}]
/// records : []

class JsonRoot {
  JsonRoot({
      String? name, 
      int? size, 
      List<Folders>? folders, 
      List<dynamic>? records,}){
    _name = name;
    _size = size;
    _folders = folders;
}

  JsonRoot.fromJson(dynamic json) {
    _name = json['name'];
    _size = json['size'];
    if (json['folders'] != null) {
      _folders = [];
      json['folders'].forEach((v) {
        _folders?.add(Folders.fromJson(v));
      });
    }
  }
  String? _name;
  int? _size;
  List<Folders>? _folders;

  String? get name => _name;
  int? get size => _size;
  List<Folders>? get folders => _folders;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['size'] = _size;
    if (_folders != null) {
      map['folders'] = _folders?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// size : 74
/// isFavorite : false
/// _id : "614d95d623cca00e93ba504f"
/// name : "f1"
/// id : "614d95d623cca00e93ba504f"

class Folders {
  Folders({
      int? size, 
      bool? isFavorite, 
      String? id, 
      String? name, 
     }){
    _size = size;
    _isFavorite = isFavorite;
    _id = id;
    _name = name;

}

  Folders.fromJson(dynamic json) {
    _size = json['size'];
    _isFavorite = json['isFavorite'];
    _name = json['name'];
    _id = json['id'];
  }
  int? _size;
  bool? _isFavorite;
  String? _id;
  String? _name;


  int? get size => _size;
  bool? get isFavorite => _isFavorite;
  String? get id => _id;
  String? get name => _name;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['size'] = _size;
    map['isFavorite'] = _isFavorite;
    map['_id'] = _id;
    map['name'] = _name;
    return map;
  }

}