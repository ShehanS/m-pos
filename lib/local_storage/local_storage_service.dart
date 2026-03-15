import 'package:flutter_bloc_app/entities/global_setting_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../entities/user_entity.dart';

/// Local storage service using Hive for persistent data storage
class LocalStorageService {
  static const String _globalSettingsBox = 'global_settings';
  static const String _userDataBox = 'user_data';

  // Singleton pattern
  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  LocalStorageService._();

  /// Initialize Hive boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters if needed (for complex objects)
    // Hive.registerAdapter(GlobalSettingsEntityAdapter());
    // Hive.registerAdapter(UserEntityAdapter());

    await Hive.openBox(_globalSettingsBox);
    await Hive.openBox(_userDataBox);
  }

  // Global Settings Operations
  Box get _globalSettingsBoxInstance => Hive.box(_globalSettingsBox);

  /// Save global settings
  Future<void> saveGlobalSettings(GlobalSettingEntity settings) async {
    await _globalSettingsBoxInstance.put('settings', settings.toJson());
  }

  /// Get global settings
  GlobalSettingEntity? getSettings() {
    final data = _globalSettingsBoxInstance.get('settings');
    if (data != null && data is Map<String, dynamic>) {
      return GlobalSettingEntity.fromJson(data);
    }
    return null;
  }

  /// Clear global settings
  Future<void> clearSettings() async {
    await _globalSettingsBoxInstance.clear();
  }

  // User Data Operations
  Box get _userDataBoxInstance => Hive.box(_userDataBox);

  /// Save user data
  Future<void> saveUserData(UserEntity user) async {
    await _userDataBoxInstance.put('user', user.toFirestore());
  }

  /// Get user data
  UserEntity? getUserData() {
    final data = _userDataBoxInstance.get('user');
    if (data != null && data is Map<String, dynamic>) {
      return UserEntity.fromJson(data);
    }
    return null;
  }

  /// Clear user data
  Future<void> clearUserData() async {
    await _userDataBoxInstance.clear();
  }

  /// Check if user is logged in
  bool get isUserLoggedIn => getUserData() != null;

  // Generic Operations
  /// Save any data with key
  Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }

  /// Get any data with key
  dynamic getData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  /// Delete data with key
  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  /// Clear entire box
  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // Specific settings operations
  /// Save app version
  Future<void> saveAppVersion(String version) async {
    await _globalSettingsBoxInstance.put('app_version', version);
  }

  /// Get app version
  String? getAppVersion() {
    return _globalSettingsBoxInstance.get('app_version');
  }

  /// Save force update flag
  Future<void> saveForceUpdate(bool forceUpdate) async {
    await _globalSettingsBoxInstance.put('force_update', forceUpdate);
  }

  /// Get force update flag
  bool getForceUpdate() {
    return _globalSettingsBoxInstance.get('force_update', defaultValue: false);
  }

  /// Save intro enabled flag
  Future<void> saveIntroEnabled(bool enabled) async {
    await _globalSettingsBoxInstance.put('intro_enabled', enabled);
  }

  /// Get intro enabled flag
  bool getIntroEnabled() {
    return _globalSettingsBoxInstance.get('intro_enabled', defaultValue: true);
  }

}
