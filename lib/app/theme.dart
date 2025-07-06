import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme flexSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff0062a0),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffd0e4ff),
  onPrimaryContainer: Color(0xff001d35),
  secondary: Color(0xff535f70),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffd7e3f8),
  onSecondaryContainer: Color(0xff101c2b),
  tertiary: Color(0xff6b5778),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xfff3daff),
  onTertiaryContainer: Color(0xff251432),
  error: Color(0xffba1a1a),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xff410002),
  background: Color(0xfffdfcff),
  onBackground: Color(0xff1a1c1e),
  surface: Color(0xfffdfcff),
  onSurface: Color(0xff1a1c1e),
  surfaceVariant: Color(0xffdfe3eb),
  onSurfaceVariant: Color(0xff42474e),
  outline: Color(0xff73777f),
  outlineVariant: Color(0xffc2c7cf),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff2f3133),
  onInverseSurface: Color(0xfff1f0f4),
  inversePrimary: Color(0xff9ccaff),
  surfaceTint: Color(0xff0062a0),
);

const ColorScheme flexSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xff9ccaff),
  onPrimary: Color(0xff003355),
  primaryContainer: Color(0xff004a78),
  onPrimaryContainer: Color(0xffd0e4ff),
  secondary: Color(0xffbbc7db),
  onSecondary: Color(0xff253141),
  secondaryContainer: Color(0xff3c4858),
  onSecondaryContainer: Color(0xffd7e3f8),
  tertiary: Color(0xffd7bde4),
  onTertiary: Color(0xff3b2948),
  tertiaryContainer: Color(0xff523f5f),
  onTertiaryContainer: Color(0xfff3daff),
  error: Color(0xffffb4ab),
  onError: Color(0xff690005),
  errorContainer: Color(0xff93000a),
  onErrorContainer: Color(0xffffdad6),
  background: Color(0xff1a1c1e),
  onBackground: Color(0xffe2e2e6),
  surface: Color(0xff1a1c1e),
  onSurface: Color(0xffe2e2e6),
  surfaceVariant: Color(0xff42474e),
  onSurfaceVariant: Color(0xffc2c7cf),
  outline: Color(0xff8c9199),
  outlineVariant: Color(0xff42474e),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xffe2e2e6),
  onInverseSurface: Color(0xff1a1c1e),
  inversePrimary: Color(0xff0062a0),
  surfaceTint: Color(0xff9ccaff),
);

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: flexSchemeLight,
      textTheme: GoogleFonts.openSansTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: flexSchemeLight.surface,
        foregroundColor: flexSchemeLight.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: flexSchemeDark,
      textTheme: GoogleFonts.openSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: flexSchemeDark.surface,
        foregroundColor: flexSchemeDark.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
