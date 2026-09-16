import 'package:drift/drift.dart';

/// Table definition for persisting individual messages belonging to a chat session.
@DataClassName('DbChatMessage')
class ChatMessages extends Table {
  /// Unique identifier of the message.
  TextColumn get id => text()();

  /// The foreign key identifier of the parent [ChatSessions] session.
  TextColumn get chatId => text()();

  /// Plain text message content.
  TextColumn get content => text()();

  /// Sender role: 'user', 'ai', or 'system'.
  TextColumn get sender => text()();

  /// Timestamp of when the message was generated/sent.
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  /// Local path to an attached image file if sent by the user.
  TextColumn get imagePath => text().nullable()();

  /// Error message if generation failed.
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
