import 'package:hive_flutter/hive_flutter.dart';

enum StorageKey { accessToken, onboardingComplete, themeMode }
enum HiveBox { defaultBox }

class LocalStorageService {
  final String boxName;

  LocalStorageService({this.boxName = 'defaultBox'});

  static Future<void> initBoxes() async {
    for (final box in HiveBox.values) {
      await Hive.openBox(box.name);
    }
  }

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<dynamic> get(StorageKey key, {dynamic defaultValue}) async {
    final box = await _getBox();
    return box.get(key.name, defaultValue: defaultValue);
  }

  Future<void> set(StorageKey key, dynamic value) async {
    final box = await _getBox();
    await box.put(key.name, value);
  }

  Future<void> delete(StorageKey key) async {
    final box = await _getBox();
    await box.delete(key.name);
  }

  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<List<dynamic>> getKeys() async {
    final box = await _getBox();
    return box.keys.toList();
  }
}

final appStorage = LocalStorageService();
