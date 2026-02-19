enum RewardType { common, rare, epic, legendary }

class Reward {
  String id;
  String title;
  String description;
  RewardType type;
  bool claimed;
  DateTime createdAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.claimed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    RewardType? type,
    bool? claimed,
    DateTime? createdAt,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      claimed: claimed ?? this.claimed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'claimed': claimed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseRewardType(json['type'] ?? 'common'),
      claimed: json['claimed'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory Reward.fromMap(Map<String, dynamic> json) {
    return Reward.fromJson(json);
  }

  static RewardType _parseRewardType(String typeString) {
    switch (typeString) {
      case 'common':
        return RewardType.common;
      case 'rare':
        return RewardType.rare;
      case 'epic':
        return RewardType.epic;
      case 'legendary':
        return RewardType.legendary;
      default:
        return RewardType.common;
    }
  }

  @override
  String toString() =>
      'Reward(id: $id, title: $title, type: ${type.toString().split('.').last}, claimed: $claimed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Reward &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
