import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get audioBottomNavigationBarItemLabel => 'Audio';

  @override
  String get videoBottomNavigationBarItemLabel => 'Video';

  @override
  String get profileBottomNavigationBarItemLabel => 'Mine';
}
