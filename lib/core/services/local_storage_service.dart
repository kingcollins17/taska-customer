import 'package:hive_flutter/hive_flutter.dart';

enum StorageKey {
  accessToken,
  onboardingComplete,
  themeMode,
  taskDraft,
  matchingState,
  reviewPromptHistory,
}
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
  
  Box get syncBox => Hive.box(boxName);

  String _getKeyString(dynamic key) {
    if (key is StorageKey) return key.name;
    return key.toString();
  }

  Future<dynamic> get(dynamic key, {dynamic defaultValue}) async {
    final box = await _getBox();
    return box.get(_getKeyString(key), defaultValue: defaultValue);
  }

  Future<void> set(dynamic key, dynamic value) async {
    final box = await _getBox();
    await box.put(_getKeyString(key), value);
  }

  Future<void> delete(dynamic key) async {
    final box = await _getBox();
    await box.delete(_getKeyString(key));
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
