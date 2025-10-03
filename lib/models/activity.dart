import 'package:flutter/foundation.dart';

@immutable
class Activity {
  final String id;
  final String name;
  final String emoji;
  final bool isActive;

  const Activity({
    required this.id,
    required this.name,
    required this.emoji,
    this.isActive = true,
  });

  Activity copyWith({
    String? id,
    String? name,
    String? emoji,
    bool? isActive,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'isActive': isActive,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, name: $name, emoji: $emoji, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Activity &&
        other.id == id &&
        other.name == name &&
        other.emoji == emoji &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ emoji.hashCode ^ isActive.hashCode;
  }
}
