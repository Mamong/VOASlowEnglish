import 'profile_menu_localizations.dart';

/// The translations for Chinese (`zh`).
class ProfileMenuLocalizationsZh extends ProfileMenuLocalizations {
  ProfileMenuLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get signInButtonLabel => '登录';

  @override
  String signedInUserGreeting(String username) {
    return '你好, $username!';
  }

  @override
  String get updateProfileTileLabel => '更新资料';

  @override
  String get darkModePreferencesHeaderTileLabel => '主题模式';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => '暗色';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => '亮色';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => '系统';

  @override
  String get signOutButtonLabel => '退出';

  @override
  String get signUpOpeningText => '没有账户?';

  @override
  String get signUpButtonLabel => '注册';
}
