import 'package:uuid/uuid.dart';

class SheddingRecord {
  final String id;
  final String reptileId;
  final DateTime shedDate;
  final String completeness; // complete, partial, stuck
  final String? notes;
  final DateTime createdAt;

  const SheddingRecord({
    required this.id,
    required this.reptileId,
    required this.shedDate,
    required this.completeness,
    this.notes,
    required this.createdAt,
  });

  factory SheddingRecord.fromMap(Map<String, dynamic> map) {
    return SheddingRecord(
      id: map['id'] as String,
      reptileId: map['reptile_id'] as String,
      shedDate: DateTime.parse(map['shed_date'] as String),
      completeness: map['completeness'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'shed_date': shedDate.toIso8601String(),
      'completeness': completeness,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}