// lib/models/folder.dart

class Folder {
  final String id;
  final String name;
  int arenaPoints;
  bool isExpanded;
  final DateTime createdAt;

  Folder({
    String? id,
    required this.name,
    this.arenaPoints = 0,
    this.isExpanded = false,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Factory constructor for creating a new Folder instance from a map
  factory Folder.fromMap(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Unnamed Folder',
      arenaPoints: json['arenaPoints'] as int? ?? 0,
      isExpanded: json['isExpanded'] as bool? ?? false,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.tryParse(json['createdAt'] as String? ?? '')
          ?? DateTime.now(),
    );
  }

  /// Method to convert a Folder instance into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arenaPoints': arenaPoints,
      'isExpanded': isExpanded,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Optional: copyWith method for immutability
  Folder copyWith({
    String? id,
    String? name,
    int? arenaPoints,
    bool? isExpanded,
    DateTime? createdAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      arenaPoints: arenaPoints ?? this.arenaPoints,
      isExpanded: isExpanded ?? this.isExpanded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Folder(id: $id, name: $name, arenaPoints: $arenaPoints, isExpanded: $isExpanded, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Folder &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              arenaPoints == other.arenaPoints;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ arenaPoints.hashCode;
}
