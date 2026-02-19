import 'reward.dart';

class Chest {
  String id;
  String rewardId;
  String rewardTitle;
  RewardType rewardType;
  bool opened;
  DateTime createdAt;
  DateTime? openedAt;

  Chest({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.rewardType,
    required this.opened,
    DateTime? createdAt,
    this.openedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Chest copyWith({
    String? id,
    String? rewardId,
    String? rewardTitle,
    RewardType? rewardType,
    bool? opened,
    DateTime? createdAt,
    DateTime? openedAt,
  }) {
    return Chest(
      id: id ?? this.id,
      rewardId: rewardId ?? this.rewardId,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardType: rewardType ?? this.rewardType,
      opened: opened ?? this.opened,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'rewardType': rewardType.toString().split('.').last,
      'opened': opened,
      'createdAt': createdAt.toIso8601String(),
      'openedAt': openedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory Chest.fromJson(Map<String, dynamic> json) {
    return Chest(
      id: json['id'] ?? '',
      rewardId: json['rewardId'] ?? '',
      rewardTitle: json['rewardTitle'] ?? '',
      rewardType: _parseRewardType(json['rewardType'] ?? 'common'),
      opened: json['opened'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      openedAt: json['openedAt'] != null ? DateTime.parse(json['openedAt']) : null,
    );
  }

  factory Chest.fromMap(Map<String, dynamic> json) {
    return Chest.fromJson(json);
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
}
