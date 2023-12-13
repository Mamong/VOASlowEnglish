import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

const _dividerThemeData = DividerThemeData(
  space: 0,
);

// If the number of properties get too big, we can start grouping them in
// classes like Flutter does with TextTheme, ButtonTheme, etc, inside ThemeData.
abstract class AppThemeData {
  ThemeData get materialThemeData;

  double screenMargin = Spacing.mediumLarge;

  double gridSpacing = Spacing.mediumLarge;

  double navBarTitleFontSize = FontSize.mediumLarge;

  Color get feedTitleColor;

  Color get feedDescColor;

  Color get feedEnColor;

  Color get feedZhColor;

  Color get feedFocusColor;

  Color get publisherNameColor;
  Color get publisherDescColor;

  Color get dividerColor;

}

class LightAppThemeData extends AppThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.black.toMaterialColor(),
    dividerTheme: _dividerThemeData,
  );

  @override
  Color get feedTitleColor => Colors.black87;

  @override
  Color get feedDescColor => Colors.black45;

  @override
  Color get feedEnColor => Colors.black87;

  @override
  Color get feedZhColor => Colors.black45;

  @override
  Color get feedFocusColor => Colors.green;

  @override
  Color get publisherNameColor => Colors.black87;

  @override
  Color get publisherDescColor => Colors.black45;

  @override
  Color get dividerColor => Colors.black12;
}

class DarkAppThemeData extends AppThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
    //toggleableActiveColor: Colors.white,
    primarySwatch: Colors.white.toMaterialColor(),
    dividerTheme: _dividerThemeData,
  );

  @override
  Color get feedTitleColor => Colors.white54;

  @override
  Color get feedDescColor => Colors.white54;

  @override
  Color get feedEnColor => Colors.white54;

  @override
  Color get feedZhColor => Colors.white30;

  @override
  Color get feedFocusColor => Colors.green;

  @override
  Color get publisherNameColor => Colors.white54;

  @override
  Color get publisherDescColor => Colors.white54;

  @override
  Color get dividerColor => Colors.white54;

}

extension on Color {
  Map<int, Color> _toSwatch() => {
    50: withOpacity(0.1),
    100: withOpacity(0.2),
    200: withOpacity(0.3),
    300: withOpacity(0.4),
    400: withOpacity(0.5),
    500: withOpacity(0.6),
    600: withOpacity(0.7),
    700: withOpacity(0.8),
    800: withOpacity(0.9),
    900: this,
  };

  MaterialColor toMaterialColor() => MaterialColor(
    value,
    _toSwatch(),
  );
}