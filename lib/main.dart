import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'features/crops/data/datasources/crop_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CropDatabaseHelper.instance.initDatabase();
  await NotificationService.instance.init();
  runApp(const MyApp());
}
