// lib/models/study_session.dart

class StudySession {
  String id;
  String cardId;
  String cardTitle; // Added
  int durationMinutes;
  DateTime startTime;
  DateTime endTime;
  DateTime createdAt;
  bool completed;
  int correctAnswers; // Added
  int totalQuestions; // Added

  StudySession({
    required this.id,
    required this.cardId,
    required this.cardTitle,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    DateTime? createdAt,
    this.completed = false,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'cardTitle': cardTitle,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completed': completed,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
    };
  }

  /// Alias for toJson() - used for Firestore compatibility
  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] ?? '',
      cardId: json['cardId'] ?? '',
      cardTitle: json['cardTitle'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completed: json['completed'] ?? false,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }

  /// Alias for fromJson() - used for Firestore compatibility
  factory StudySession.fromMap(Map<String, dynamic> json) {
    return StudySession.fromJson(json);
  }

  /// Optional: copyWith method for immutability
  StudySession copyWith({
    String? id,
    String? cardId,
    String? cardTitle,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    bool? completed,
    int? correctAnswers,
    int? totalQuestions,
  }) {
    return StudySession(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      cardTitle: cardTitle ?? this.cardTitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  @override
  String toString() =>
      'StudySession(id: $id, cardId: $cardId, cardTitle: $cardTitle, durationMinutes: $durationMinutes, completed: $completed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StudySession &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              cardId == other.cardId;

  @override
  int get hashCode => id.hashCode ^ cardId.hashCode;
}
