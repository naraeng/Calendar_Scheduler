import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scheduler/model/scheduling.dart';

part 'drift_database.g.dart';

@DriftDatabase(tables: [
  Schedules,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());
  Stream<List<Schedule>> watchSchedules(DateTime date) => (select(schedules)
        ..where(
          (tbl) => tbl.date.equals(date),
        ))
      .watch();

  Future<int> createSchedules(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> removeSchedules(int id) => (delete(schedules)
        ..where(
          (tbl) => tbl.id.equals(id),
        ))
      .go();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase((() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  }));
}
