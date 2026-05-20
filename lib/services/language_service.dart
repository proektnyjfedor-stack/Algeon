library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { ru, en }

class LanguageService extends ChangeNotifier {
  LanguageService._();

  static final LanguageService instance = LanguageService._();
  static const String _keyLanguage = 'app_language';

  SharedPreferences? _prefs;
  AppLanguage _language = AppLanguage.ru;

  AppLanguage get language => _language;
  bool get isEnglish => _language == AppLanguage.en;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_keyLanguage) ?? 'ru';
    _language = raw == 'en' ? AppLanguage.en : AppLanguage.ru;
  }

  Future<void> setLanguage(AppLanguage next) async {
    if (_language == next) return;
    _language = next;
    await _prefs?.setString(_keyLanguage, next == AppLanguage.en ? 'en' : 'ru');
    notifyListeners();
  }

  String t(String key) {
    final m = _localized[key];
    if (m == null) return key;
    return isEnglish ? (m.en.isNotEmpty ? m.en : m.ru) : m.ru;
  }
}

class _Pair {
  const _Pair(this.ru, this.en);
  final String ru;
  final String en;
}

const Map<String, _Pair> _localized = {
  'lang.ru': _Pair('Русский', 'Russian'),
  'lang.en': _Pair('Английский', 'English'),
  'common.save': _Pair('Сохранить', 'Save'),
  'common.cancel': _Pair('Отмена', 'Cancel'),
  'common.close': _Pair('Закрыть', 'Close'),
  'common.edit': _Pair('Изменить', 'Edit'),
  'common.open': _Pair('Открыть', 'Open'),
  'common.continue': _Pair('Продолжить', 'Continue'),
  'common.loading': _Pair('Загрузка...', 'Loading...'),
  'nav.learn': _Pair('Задачи', 'Tasks'),
  'nav.practice': _Pair('Практика', 'Practice'),
  'nav.achievements': _Pair('Награды', 'Achievements'),
  'nav.profile': _Pair('Профиль', 'Profile'),
  'onboarding.skip': _Pair('Пропустить', 'Skip'),
  'onboarding.customizeTitle':
      _Pair('Создай своего персонажа', 'Create your character'),
  'onboarding.random': _Pair('Случайный', 'Random'),
  'onboarding.great': _Pair('Отлично!', 'Great!'),
  'onboarding.letsMeet':
      _Pair('Теперь давай познакомимся', 'Now let’s get to know each other'),
  'onboarding.whatsName': _Pair('Как тебя зовут?', 'What’s your name?'),
  'onboarding.enterName': _Pair('Введи своё имя', 'Enter your name'),
  'onboarding.pickGrade': _Pair('Выбери класс', 'Choose your grade'),
  'onboarding.pickGradeSub':
      _Pair('Мы подберём подходящие задания', 'We’ll choose suitable tasks'),
  'onboarding.startLearning': _Pair('Начать обучение', 'Start learning'),
  'home.dailyGoal': _Pair('Дневная цель', 'Daily goal'),
  'home.startText': _Pair('Начни решать — цель 10 задач в день',
      'Start solving — the goal is 10 tasks a day'),
  'home.goalReached': _Pair('Цель достигнута! 🎉', 'Goal reached! 🎉'),
  'home.toGoal': _Pair('Ещё {count} до цели', '{count} more to reach the goal'),
  'home.continue': _Pair('Продолжить', 'Continue'),
  'home.continueSub': _Pair('С текущего места', 'Pick up where you left off'),
  'home.practiceSub': _Pair('Быстрые задания', 'Quick tasks'),
  'home.achievementsSub':
      _Pair('Достижения и прогресс', 'Achievements and progress'),
  'home.topics': _Pair('Темы {grade} класса', 'Grade {grade} topics'),
  'home.greeting': _Pair('Привет, {name}', 'Hi, {name}'),
  'home.gradeProgress': _Pair('{grade} класс освоен на {percent}%',
      'Grade {grade}: {percent}% complete'),
  'home.solvedShort': _Pair('решено', 'solved'),
  'home.accuracyShort': _Pair('точность', 'accuracy'),
  'home.streakShort': _Pair('серия', 'streak'),
  'home.todayShort': _Pair('сегодня', 'today'),
  'home.nextStep': _Pair('Следующий шаг', 'Next step'),
  'home.gradeDoneTitle': _Pair('Класс пройден', 'Grade completed'),
  'home.gradeDoneSub': _Pair('Можно закрепить знания в практике',
      'You can review and strengthen your skills in practice'),
  'home.statusStart': _Pair('начать', 'Start'),
  'home.statusInProgress': _Pair('в процессе', 'In progress'),
  'home.statusDone': _Pair('готово', 'Done'),
  'install.title':
      _Pair('Добавь Algeon на главный экран', 'Add Algeon to your home screen'),
  'install.subtitle': _Pair(
      'Так сайт будет открываться как приложение: быстрее и без лишних вкладок.',
      'Open the site like an app: faster and without extra browser tabs.'),
  'install.iosTitle': _Pair('iPhone / iPad', 'iPhone / iPad'),
  'install.iosStep1':
      _Pair('Открой сайт в Safari.', 'Open the site in Safari.'),
  'install.iosStep2':
      _Pair('Нажми кнопку «Поделиться».', 'Tap the Share button.'),
  'install.iosStep3': _Pair('Выбери «На экран “Домой”» и нажми «Добавить».',
      'Choose “Add to Home Screen”, then tap Add.'),
  'install.androidTitle': _Pair('Android', 'Android'),
  'install.androidStep1':
      _Pair('Открой сайт в Chrome.', 'Open the site in Chrome.'),
  'install.androidStep2': _Pair(
      'Нажми меню с тремя точками в правом верхнем углу.',
      'Tap the three-dot menu in the top-right corner.'),
  'install.androidStep3': _Pair(
      'Выбери «Добавить на главный экран» или «Установить приложение».',
      'Choose “Add to Home screen” or “Install app”.'),
  'settings.title': _Pair('Настройки', 'Settings'),
  'settings.name': _Pair('Имя', 'Name'),
  'settings.avatar': _Pair('Аватарка', 'Avatar'),
  'settings.avatarSub': _Pair('Выбрать из готовых, конструктор или фото',
      'Choose preset, builder, or photo'),
  'settings.grade': _Pair('Класс', 'Grade'),
  'settings.language': _Pair('Язык', 'Language'),
  'settings.autoTheme': _Pair('Как на телефоне', 'Match device theme'),
  'settings.autoThemeOn': _Pair(
      'Включено: сайт повторяет светлую/тёмную тему устройства',
      'Enabled: the site follows the device light/dark theme'),
  'settings.autoThemeOff':
      _Pair('Выключено: ручной выбор', 'Off: manual choice'),
  'settings.darkTheme': _Pair('Тёмная тема', 'Dark theme'),
  'settings.enabled': _Pair('Включена', 'Enabled'),
  'settings.disabled': _Pair('Выключена', 'Disabled'),
  'error.notFound': _Pair('Страница не найдена', 'Page not found'),
  'error.toHome': _Pair('На главную', 'Go to home'),
  'main.initFail':
      _Pair('Не удалось запустить Algeon.', 'Failed to start Algeon.'),
  'main.loading': _Pair('Загрузка…', 'Loading…'),
  'main.refreshHint': _Pair(
      'Попробуйте обновить страницу (жёсткое обновление: Ctrl+Shift+R или Cmd+Shift+R) или режим инкогнито.',
      'Try refreshing the page (hard refresh: Ctrl+Shift+R or Cmd+Shift+R) or use incognito mode.'),
  'topic.theory': _Pair('Теория', 'Theory'),
  'topic.tasksCount': _Pair('{count} задач', '{count} tasks'),
  'topic.definition': _Pair('Определение', 'Definition'),
  'topic.formula': _Pair('Формула', 'Formula'),
  'topic.example': _Pair('Пример', 'Example'),
  'topic.tip': _Pair('Совет', 'Tip'),
  'topic.table': _Pair('Таблица', 'Table'),
  'topic.algorithm': _Pair('Алгоритм', 'Algorithm'),
  'topic.startTasks': _Pair('Начать задачи', 'Start tasks'),
  'practice.title': _Pair('Практика', 'Practice'),
  'practice.subtitle': _Pair('Закрепляй знания', 'Practice what you know'),
  'practice.quickTest': _Pair('Быстрый тест', 'Quick test'),
  'practice.gradeSuffix': _Pair('{grade} класс', 'Grade {grade}'),
  'practice.start': _Pair('НАЧАТЬ', 'START'),
  'practice.continue': _Pair('Продолжить', 'Continue'),
  'practice.stats': _Pair('Статистика', 'Statistics'),
  'practice.solved': _Pair('Решено', 'Solved'),
  'practice.accuracy': _Pair('Точность', 'Accuracy'),
  'practice.streak': _Pair('Серия', 'Streak'),
  'practice.quickTestTopic': _Pair('Быстрый тест', 'Quick test'),
  'ach.title': _Pair('Награды', 'Achievements'),
  'ach.subtitle': _Pair(
      'Собирай достижения за успехи', 'Collect achievements for your progress'),
  'ach.progress': _Pair('Прогресс', 'Progress'),
  'ach.unlocked': _Pair('Получено ({count})', 'Unlocked ({count})'),
  'ach.locked': _Pair('Заблокировано ({count})', 'Locked ({count})'),
  'ach.completed': _Pair('Выполнено!', 'Complete!'),
  'ach.tasksProgress':
      _Pair('{current} / {target} задач', '{current} / {target} tasks'),
  'ach.daysProgress':
      _Pair('{current} / {target} дней', '{current} / {target} days'),
  'ach.minAttempts': _Pair('(мин. 20 попыток)', '(min. 20 attempts)'),
  'ach.perfectSessionProgress':
      _Pair('100% в сессии (мин. 5 задач)', '100% in a session (min. 5 tasks)'),
  'ach.hint.firstTask': _Pair(
      'Открой любую тему и реши хотя бы 1 задачу с правильным ответом.',
      'Open any topic and solve at least 1 task correctly.'),
  'ach.hint.tasksSolved': _Pair(
      'Нужно накапливать общее число правильно решённых задач. Сейчас цель: {target}.',
      'Build up your total number of correctly solved tasks. Current target: {target}.'),
  'ach.hint.streak': _Pair(
      'Решай хотя бы 1 задачу каждый день. Пропуск дня сбрасывает серию.',
      'Solve at least 1 task daily. Missing a day resets your streak.'),
  'ach.hint.accuracy': _Pair(
      'Держи точность не ниже {target}% после минимум 20 попыток.',
      'Keep your accuracy at or above {target}% after at least 20 attempts.'),
  'ach.hint.perfect': _Pair(
      'Пройди одну сессию минимум из 5 задач без единой ошибки.',
      'Complete one session of at least 5 tasks without a single mistake.'),
  'ach.receivedOn': _Pair('Получено {date}', 'Received on {date}'),
  'ach.notReceivedYet': _Pair('Ещё не получено', 'Not unlocked yet'),
  'ach.skinsUnlocked':
      _Pair('Открыты скины аватара: {names}', 'Unlocked avatar skins: {names}'),
  'task.inequalityHint': _Pair(
      'Подсказка: для неравенств используй >= и <= (или кнопки ≥ и ≤).',
      'Hint: for inequalities use >= and <= (or buttons ≥ and ≤).'),
  'task.showHint': _Pair('Показать подсказку', 'Show hint'),
  'task.enterAnswer': _Pair('Введи ответ', 'Enter answer'),
  'task.explainTogether': _Pair('Разберём вместе', 'Let’s solve it together'),
  'task.nextStep': _Pair('Следующий шаг', 'Next step'),
  'task.hideKeyboard': _Pair('Свернуть клавиатуру', 'Hide keyboard'),
  'task.continue': _Pair('Продолжить', 'Continue'),
  'task.finish': _Pair('Завершить', 'Finish'),
  'task.next': _Pair('Далее', 'Next'),
  'task.gotIt': _Pair('Понятно', 'Got it'),
  'task.check': _Pair('Проверить', 'Check'),
  'task.inputPreview': _Pair('Ввод...', 'Input...'),
  'task.dontKnow':
      _Pair('Не знаю — покажи ответ', 'I don’t know — show the answer'),
  'task.exitTitle': _Pair('Выйти?', 'Exit?'),
  'task.exitBody':
      _Pair('Твой прогресс будет сохранён.', 'Your progress will be saved.'),
  'task.stay': _Pair('Остаться', 'Stay'),
  'task.exit': _Pair('Выйти', 'Exit'),
  'task.newAchievement': _Pair('Новое достижение!', 'New achievement!'),
  'task.skin': _Pair('Скин', 'Skin'),
  'task.cool': _Pair('Круто', 'Awesome'),
  'summary.excellent': _Pair('Превосходно!', 'Excellent!'),
  'summary.great': _Pair('Отличная работа!', 'Great job!'),
  'summary.good': _Pair('Хороший результат!', 'Good result!'),
  'summary.notBad': _Pair('Неплохо!', 'Not bad!'),
  'summary.keepLearning': _Pair('Продолжай учиться!', 'Keep learning!'),
  'summary.correct': _Pair('Верно', 'Correct'),
  'summary.wrong': _Pair('Ошибок', 'Mistakes'),
  'summary.tasks': _Pair('Задач', 'Tasks'),
  'summary.time': _Pair('Время', 'Time'),
  'summary.days': _Pair('{count} дней', '{count} days'),
  'summary.newAchievements': _Pair('Новые достижения!', 'New achievements!'),
  'summary.retryWrong':
      _Pair('Повторить ошибки ({count})', 'Retry mistakes ({count})'),
  'summary.toHome': _Pair('На главную', 'Home'),
  'summary.wrongWorkTopic': _Pair('Работа над ошибками', 'Mistake review'),
  'home.practice': _Pair('Практика', 'Practice'),
  'profile.editName': _Pair('Изменить имя', 'Edit name'),
  'profile.nameExample': _Pair('Например: Маша', 'For example: Alex'),
  'profile.nameUpdated': _Pair('Имя обновлено', 'Name updated'),
  'profile.photoUpdated':
      _Pair('Фото аватарки обновлено', 'Profile photo updated'),
  'profile.photoPickFailed': _Pair(
      'Не удалось выбрать фото: {error}', 'Could not pick photo: {error}'),
  'profile.pickGrade': _Pair('Выбери класс', 'Choose your grade'),
  'profile.saveGrade': _Pair('Сохранить класс', 'Save grade'),
  'profile.gradeUpdated': _Pair('Класс обновлён', 'Grade updated'),
  'profile.customAvatarSaved':
      _Pair('Кастомная аватарка сохранена', 'Custom avatar saved'),
  'profile.pickAvatar': _Pair('Выбери аватарку', 'Choose an avatar'),
  'profile.skinLockedHint': _Pair(
      'Этот скин откроется в наградах', 'This skin unlocks via achievements'),
  'profile.avatarUpdated': _Pair('Аватарка обновлена', 'Avatar updated'),
  'profile.choosePresetAvatar':
      _Pair('Выбрать готовую аватарку', 'Choose preset avatar'),
  'profile.openAvatarBuilder':
      _Pair('Открыть конструктор аватара', 'Open avatar builder'),
  'profile.uploadPhoto':
      _Pair('Загрузить фото из галереи', 'Upload photo from gallery'),
  'profile.solved': _Pair('решено', 'solved'),
  'profile.accuracy': _Pair('точность', 'accuracy'),
  'profile.streak': _Pair('серия', 'streak'),
  'profile.level': _Pair('Ур. {level}', 'Lvl {level}'),
  'profile.rewardsCount': _Pair('{count} наград', '{count} rewards'),
  'profile.todayPlus': _Pair('Сегодня +{count}', 'Today +{count}'),
  'onboarding.hair': _Pair('Причёска', 'Hair'),
  'onboarding.expression': _Pair('Эмоция', 'Expression'),
  'onboarding.skin': _Pair('Кожа', 'Skin'),
  'onboarding.hairColor': _Pair('Цвет волос', 'Hair color'),
  'onboarding.clothes': _Pair('Одежда', 'Clothes'),
  'onboarding.accessory': _Pair('Аксессуар', 'Accessory'),
  'onboarding.presetStyle': _Pair('Готовый стиль', 'Preset style'),
  'onboarding.background': _Pair('Фон', 'Background'),
  'keyboard.clear': _Pair('Очистить', 'Clear'),
  'keyboard.space': _Pair('Пробел', 'Space'),
};
