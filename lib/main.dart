import 'package:flutter/material.dart';
import 'package:scheduler/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_it/get_it.dart';
import 'package:scheduler/database/drift_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final database = LocalDatabase();

  GetIt.I.registerSingleton<LocalDatabase>(database);

  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
