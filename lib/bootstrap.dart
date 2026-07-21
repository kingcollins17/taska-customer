import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seeker_app/core/services/device_tray.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await LocalStorageService.initBoxes();
  await DeviceTray.instance.initialize();
  await DeviceTray.instance.requestPermission();
}
