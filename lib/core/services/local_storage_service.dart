import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  final String boxName;

  LocalStorageService({this.boxName = 'default_box'});

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final box = await _getBox();
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> set(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
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
