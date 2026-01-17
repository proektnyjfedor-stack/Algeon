/// Локальный сервис авторизации
/// 
/// Автоматически регистрирует пользователя при первом входе
/// Сохраняет сессию между запусками

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyUser = 'current_user';
  static const String _keyUsers = 'registered_users';
  
  static SharedPreferences? _prefs;
  static AppUser? _currentUser;
  
  /// Инициализация
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCurrentUser();
    _log('AuthService инициализирован');
  }
  
  /// Текущий пользователь
  static AppUser? get currentUser => _currentUser;
  
  /// Проверка авторизации
  static bool get isLoggedIn => _currentUser != null;
  
  /// Загрузка текущего пользователя из SharedPreferences
  static void _loadCurrentUser() {
    final userData = _prefs?.getString(_keyUser);
    if (userData != null) {
      try {
        final json = jsonDecode(userData) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(json);
        _log('Пользователь загружен: ${_currentUser?.email}');
      } catch (e) {
        _log('Ошибка загрузки: $e');
        _currentUser = null;
      }
    }
  }
  
  /// Регистрация
  static Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _log('Регистрация: $email');
    
    final users = _getRegisteredUsers();
    if (users.containsKey(email)) {
      throw 'Этот email уже зарегистрирован';
    }
    
    final user = AppUser(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: displayName ?? email.split('@').first,
      grade: null,
      createdAt: DateTime.now(),
    );
    
    users[email] = {
      'password': password,
      'user': user.toJson(),
    };
    await _saveRegisteredUsers(users);
    await _setCurrentUser(user);
    
    _log('Регистрация успешна: ${user.uid}');
    return user;
  }
  
  /// Вход (с авто-регистрацией)
  static Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _log('Вход: $email');
    
    final users = _getRegisteredUsers();
    
    // Автоматическая регистрация
    if (!users.containsKey(email)) {
      _log('Автоматическая регистрация...');
      return await signUp(
        email: email,
        password: password,
        displayName: email.split('@').first,
      );
    }
    
    final userData = users[email] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw 'Неверный пароль';
    }
    
    final user = AppUser.fromJson(userData['user'] as Map<String, dynamic>);
    await _setCurrentUser(user);
    
    _log('Вход успешен: ${user.uid}');
    return user;
  }
  
  /// Обновить имя пользователя
  static Future<void> updateDisplayName(String name) async {
    if (_currentUser == null) return;
    
    _log('Обновление имени: $name');
    
    final updatedUser = _currentUser!.copyWith(displayName: name);
    
    // Обновляем в списке пользователей
    final users = _getRegisteredUsers();
    if (users.containsKey(_currentUser!.email)) {
      final userData = users[_currentUser!.email] as Map<String, dynamic>;
      userData['user'] = updatedUser.toJson();
      await _saveRegisteredUsers(users);
    }
    
    // Обновляем текущего пользователя
    await _setCurrentUser(updatedUser);
  }
  
  /// Выход
  static Future<void> signOut() async {
    _log('Выход');
    _currentUser = null;
    await _prefs?.remove(_keyUser);
  }
  
  /// Установка текущего пользователя
  static Future<void> _setCurrentUser(AppUser user) async {
    _currentUser = user;
    await _prefs?.setString(_keyUser, jsonEncode(user.toJson()));
  }
  
  /// Получить зарегистрированных пользователей
  static Map<String, dynamic> _getRegisteredUsers() {
    final data = _prefs?.getString(_keyUsers);
    if (data == null) return {};
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  /// Сохранить пользователей
  static Future<void> _saveRegisteredUsers(Map<String, dynamic> users) async {
    await _prefs?.setString(_keyUsers, jsonEncode(users));
  }
  
  static void _log(String message) {
    // ignore: avoid_print
    print('[AuthService] $message');
  }
}
