import 'package:drift/drift.dart';

/// Table definition for storing downloaded & installed AI models on device.
/// Allows downloading multiple models and seamlessly switching the active one.
class UserAiModels extends Table {
  /// Unique identifier of the model (e.g., 'qwen3_0_6b', 'mobilellm_r1_5_950m', 'qwen3_1_7b').
  TextColumn get id => text()();

  /// Human-readable model display name (e.g. 'Qwen3 0.6B').
  TextColumn get displayName => text()();

  /// Semantic model tier: 'fast', 'reasoning', 'quality'.
  TextColumn get tier => text()();

  /// Model revision or version string.
  TextColumn get version => text().withDefault(const Constant('1.0.0'))();

  /// Local file path on device storage where the model artifact is saved.
  TextColumn get filePath => text()();

  /// Size of the model artifact on disk in bytes.
  Int64Column get fileSizeBytes => int64()();

  /// SHA-256 integrity checksum.
  TextColumn get sha256 => text()();

  /// Whether the model passed SHA-256 verification and local health check.
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();

  /// Whether this model is currently the active model used for inference.
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  /// Timestamp when model download & verification completed.
  DateTimeColumn get installedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the user last switched to or used this model.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
