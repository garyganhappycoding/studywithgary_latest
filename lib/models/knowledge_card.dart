// lib/models/knowledge_card.dart

class KnowledgeCard {
  String id;
  String folderId;
  String title;
  String notes;
  String understanding;
  String practiceQuestion;
  String practiceAnswer;
  int level;
  DateTime createdAt;
  DateTime lastModified;

  KnowledgeCard({
    required this.id,
    required this.folderId,
    required this.title,
    required this.notes,
    required this.understanding,
    required this.practiceQuestion,
    required this.practiceAnswer,
    required this.level,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderId': folderId,
      'title': title,
      'notes': notes,
      'understanding': understanding,
      'practiceQuestion': practiceQuestion,
      'practiceAnswer': practiceAnswer,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Alias for toJson() - used for Firestore compatibility
  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory KnowledgeCard.fromJson(Map<String, dynamic> json) {
    return KnowledgeCard(
      id: json['id'] ?? '',
      folderId: json['folderId'] ?? '',
      title: json['title'] ?? '',
      notes: json['notes'] ?? '',
      understanding: json['understanding'] ?? '',
      practiceQuestion: json['practiceQuestion'] ?? '',
      practiceAnswer: json['practiceAnswer'] ?? '',
      level: json['level'] ?? 1,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastModified: DateTime.parse(json['lastModified'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Alias for fromJson() - used for Firestore compatibility
  factory KnowledgeCard.fromMap(Map<String, dynamic> json) {
    return KnowledgeCard.fromJson(json);
  }

  KnowledgeCard copyWith({
    String? id,
    String? folderId,
    String? title,
    String? notes,
    String? understanding,
    String? practiceQuestion,
    String? practiceAnswer,
    int? level,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return KnowledgeCard(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      understanding: understanding ?? this.understanding,
      practiceQuestion: practiceQuestion ?? this.practiceQuestion,
      practiceAnswer: practiceAnswer ?? this.practiceAnswer,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  String toString() =>
      'KnowledgeCard(id: $id, title: $title, folderId: $folderId, level: $level)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is KnowledgeCard &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
