import 'package:flutter/material.dart';

import 'app.dart';
import 'features/featues_export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

