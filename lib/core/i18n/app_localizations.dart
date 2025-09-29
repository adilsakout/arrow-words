import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('fr'), Locale('ar')];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Arrow Words',
      'dailyPuzzle': 'Daily Puzzle',
      'puzzlePacks': 'Puzzle Packs',
      'importJson': 'Import JSON',
      'continueLast': 'Continue Last Puzzle',
      'settings': 'Settings',
      'timer': 'Timer',
      'hints': 'Hints',
      'revealLetter': 'Reveal Letter',
      'revealWord': 'Reveal Word',
      'checkWord': 'Check Word',
      'autoCheck': 'Auto-check',
      'highlightErrors': 'Highlight errors',
      'showTimer': 'Show timer',
      'soundEffects': 'Sound effects',
      'haptics': 'Haptics',
      'theme': 'Theme',
      'language': 'Language',
      'systemTheme': 'System',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'highContrastTheme': 'High contrast',
      'pencilMode': 'Pencil',
      'clear': 'Clear',
      'backspace': 'Backspace',
      'celebrationTitle': 'Brilliant!',
      'celebrationMessage': 'Every clue is solved. Fantastic work!',
      'resume': 'Resume',
      'newGame': 'New game',
      'importInstructions': 'Paste a puzzle JSON string below',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'hintRemaining': '{count} hints',
      'mistakes': 'Mistakes',
      'autoSave': 'Autosave active',
      'dailyUnavailable': 'Daily puzzle unavailable',
      'importSuccess': 'Puzzle imported.',
    },
    'fr': {
      'appTitle': 'Mots Fléchés',
      'dailyPuzzle': 'Grille du jour',
      'puzzlePacks': 'Packs',
      'importJson': 'Importer JSON',
      'continueLast': 'Continuer',
      'settings': 'Paramètres',
      'timer': 'Minuteur',
      'hints': 'Indices',
      'revealLetter': 'Révéler lettre',
      'revealWord': 'Révéler mot',
      'checkWord': 'Vérifier mot',
      'autoCheck': 'Auto-vérification',
      'highlightErrors': 'Surbrillance erreurs',
      'showTimer': 'Afficher minuteur',
      'soundEffects': 'Effets sonores',
      'haptics': 'Vibrations',
      'theme': 'Thème',
      'language': 'Langue',
      'systemTheme': 'Système',
      'lightTheme': 'Clair',
      'darkTheme': 'Sombre',
      'highContrastTheme': 'Contraste élevé',
      'pencilMode': 'Crayon',
      'clear': 'Effacer',
      'backspace': 'Retour',
      'celebrationTitle': 'Bravo !',
      'celebrationMessage': 'Toutes les définitions sont résolues.',
      'resume': 'Reprendre',
      'newGame': 'Nouvelle partie',
      'importInstructions': 'Collez un JSON de grille ci-dessous',
      'confirm': 'Confirmer',
      'cancel': 'Annuler',
      'hintRemaining': '{count} indices',
      'mistakes': 'Erreurs',
      'autoSave': 'Sauvegarde auto',
      'dailyUnavailable': 'Grille du jour indisponible',
      'importSuccess': 'Grille importée.',
    },
    'ar': {
      'appTitle': 'كلمات السهم',
      'dailyPuzzle': 'لغز اليوم',
      'puzzlePacks': 'حزم الألغاز',
      'importJson': 'استيراد JSON',
      'continueLast': 'متابعة',
      'settings': 'الإعدادات',
      'timer': 'المؤقت',
      'hints': 'تلميحات',
      'revealLetter': 'كشف حرف',
      'revealWord': 'كشف كلمة',
      'checkWord': 'تحقق من كلمة',
      'autoCheck': 'تحقق تلقائي',
      'highlightErrors': 'تمييز الأخطاء',
      'showTimer': 'عرض المؤقت',
      'soundEffects': 'تأثيرات صوتية',
      'haptics': 'اهتزاز',
      'theme': 'السمة',
      'language': 'اللغة',
      'systemTheme': 'النظام',
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'highContrastTheme': 'تباين عالٍ',
      'pencilMode': 'قلم',
      'clear': 'مسح',
      'backspace': 'حذف',
      'celebrationTitle': 'رائع!',
      'celebrationMessage': 'تم حل جميع التعريفات.',
      'resume': 'متابعة',
      'newGame': 'لعبة جديدة',
      'importInstructions': 'الصق JSON للغز أدناه',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'hintRemaining': '{count} تلميحات',
      'mistakes': 'أخطاء',
      'autoSave': 'حفظ تلقائي',
      'dailyUnavailable': 'لغز اليوم غير متاح',
      'importSuccess': 'تم استيراد اللغز.',
    },
  };

  String _value(String key) {
    final table = _localizedValues[locale.languageCode];
    if (table != null && table.containsKey(key)) {
      return table[key]!;
    }
    return _localizedValues['en']![key] ?? key;
  }

  String appString(String key, {Map<String, String> params = const {}}) {
    var result = _value(key);
    params.forEach((name, value) {
      result = result.replaceAll('{$name}', value);
    });
    return result;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
