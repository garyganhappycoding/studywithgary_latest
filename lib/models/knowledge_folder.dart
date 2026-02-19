class KnowledgeFolder {
  String id;
  String name;
  String description;
  bool isExpanded;  // ✅ ADD THIS
  DateTime createdAt;


  KnowledgeFolder({
    required this.id,
    required this.name,
    required this.description,
    this.isExpanded = false,  // ✅ ADD THIS
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


  // ✅ ADD copyWith METHOD
  KnowledgeFolder copyWith({
    String? id,
    String? name,
    String? description,
    bool? isExpanded,
    DateTime? createdAt,
  }) {
    return KnowledgeFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isExpanded: isExpanded ?? this.isExpanded,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isExpanded': isExpanded,  // ✅ ADD THIS
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory KnowledgeFolder.fromJson(Map<String, dynamic> json) {
    return KnowledgeFolder(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isExpanded: json['isExpanded'] ?? false,  // ✅ ADD THIS
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

