import 'package:drift/drift.dart';

/// Table definition for persisting chat sessions / conversations in Bunji.
class ChatSessions extends Table {
  /// Unique identifier (e.g. UUID).
  TextColumn get id => text()();

  /// Generated title of the conversation.
  TextColumn get title => text()();

  /// Cover image file path or URL if an image was the first thing sent.
  TextColumn get coverImagePath => text().nullable()();

  /// Model ID used for the conversation.
  TextColumn get modelId => text().nullable()();

  /// Whether this conversation is pinned to the top.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// Timestamp when the chat was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp of the last message / update.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
