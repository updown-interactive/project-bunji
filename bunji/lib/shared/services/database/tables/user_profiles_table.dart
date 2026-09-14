import 'package:drift/drift.dart';

/// Table definition for storing basic user profile details.
class UserProfiles extends Table {
  /// Unique identifier (e.g. Supabase Auth UID or local UUID).
  TextColumn get id => text()();

  /// User's full name.
  TextColumn get name => text()();

  /// Date of birth.
  DateTimeColumn get dob => dateTime().nullable()();

  /// Email address.
  TextColumn get email => text().nullable()();

  /// Phone number.
  TextColumn get phone => text().nullable()();

  /// Gender (e.g. Male, Female, Non-binary, Other, Prefer not to say).
  TextColumn get gender => text().nullable()();

  /// Avatar URL or local image path if any.
  TextColumn get avatarUrl => text().nullable()();

  /// Timestamp of creation.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp of last update.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
