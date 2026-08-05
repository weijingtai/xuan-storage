import 'package:drift/drift.dart';

/// Stores blob timestamps as UTC epoch microseconds and always restores UTC.
class BlobUtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const BlobUtcDateTimeConverter();

  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toUtc();

  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
