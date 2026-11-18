import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

/// Every color in the app, resolved for the active theme (EVOGENCY or
/// Classic) and mode (dark or light). Callers never need to know about
/// either setting - `AppColors.signal` etc. always read the right value.
///
/// EVOGENCY: the evogencyglobal.com brand as of the 2026-11-16 olive
/// palette (site commit c3ce1f2). Warm near black #0B0A09, cream type
/// #F4F1EA, warm grays, and the olive accent #A3B06A to #7D8A45
/// (`--color-accent-cyan` / `--color-accent-teal` in the site's
/// globals.css, which kept their old names). Classic: the original
/// red/orange app look, white shadowed cards and solid red bars.
///
/// Contrast (WCAG 2.2 AA, checked 2026-11-17): every text color here is at
/// least 4.5:1 on background, surface, and surfaceSunken in its own theme
/// and mode, and on its own 10% tint (status tags). [fieldLine] is at
/// least 3:1 against the surfaces an input sits on. The widget tests run
/// Flutter's textContrastGuideline over every screen to keep it that way.
class AppColors {
  AppColors._();

  static bool get _isDark => AppSettings.isDarkMode.value;
  static bool get isClassic => AppSettings.themeStyle.value == AppThemeStyle.classic;

  static Color _pick({
    required int brandDark,
    required int brandLight,
    required int classicDark,
    required int classicLight,
  }) {
    if (isClassic) return Color(_isDark ? classicDark : classicLight);
    return Color(_isDark ? brandDark : brandLight);
  }

  /// Page background.
  static Color get background => _pick(
        brandDark: 0xFF0B0A09,
        brandLight: 0xFFF7F3EA,
        classicDark: 0xFF121212,
        classicLight: 0xFFF4F5F7,
      );

  /// Panel surface (cards, forms, result blocks): the site's warm glass.
  static Color get surface => _pick(
        brandDark: 0xFF151412,
        brandLight: 0xFFFFFDF8,
        classicDark: 0xFF1E1E1E,
        classicLight: 0xFFFFFFFF,
      );

  /// Recessed surface: inputs, assistant bubbles, table headers.
  static Color get surfaceSunken => _pick(
        brandDark: 0xFF1C1B18,
        brandLight: 0xFFEFE9DC,
        classicDark: 0xFF262628,
        classicLight: 0xFFF7F7F8,
      );

  /// Decorative hairline / divider. Never the only edge of a control.
  static Color get line => _pick(
        brandDark: 0xFF2C2A26,
        brandLight: 0xFFDED6C6,
        classicDark: 0xFF3A3A3E,
        classicLight: 0xFFE5E7EB,
      );

  /// Border of inputs and dropdowns: 3:1 or better against the surface,
  /// because it is the only thing that shows where the field is.
  static Color get fieldLine => _pick(
        brandDark: 0xFF78736A,
        brandLight: 0xFF8A8172,
        classicDark: 0xFF7A7A80,
        classicLight: 0xFF80858E,
      );

  /// The accent: site olive (a darker olive in light mode, since #A3B06A
  /// is too pale for text on cream) or the original brand red in Classic.
  static Color get signal => _pick(
        brandDark: 0xFFA3B06A,
        brandLight: 0xFF5D6630,
        classicDark: 0xFFF47370,
        classicLight: 0xFFC62828,
      );

  /// Second stop of the brand gradient (#7D8A45). In light mode both stops
  /// darken so white text stays readable on them.
  static Color get signalDeep => _pick(
        brandDark: 0xFF7D8A45,
        brandLight: 0xFF4A5226,
        classicDark: 0xFFF47370,
        classicLight: 0xFFC62828,
      );

  /// The site's primary button and headline accent: olive at 135°.
  static LinearGradient get signalGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [signal, signalDeep],
      );

  /// Text/icons sitting on a solid signal fill. Brand dark uses the site's
  /// button ink (#141A08, 4.7:1 even on the dark end of the gradient).
  static Color get onSignal => _pick(
        brandDark: 0xFF141A08,
        brandLight: 0xFFFFFFFF,
        classicDark: 0xFF1A0606,
        classicLight: 0xFFFFFFFF,
      );

  /// Keyboard focus ring. Same as the site's `:focus-visible` outline.
  static Color get focus => signal;

  /// Signal tint for pills, tags, and the user chat bubble.
  static Color get signalSoft => signal.withValues(alpha: _isDark ? 0.12 : 0.10);

  /// Signal ring around tinted elements.
  static Color get signalRing => signal.withValues(alpha: 0.30);

  /// Primary heading/body text. Brand dark is the site's body cream.
  static Color get text => _pick(
        brandDark: 0xFFF4F1EA,
        brandLight: 0xFF14110C,
        classicDark: 0xFFF3F4F6,
        classicLight: 0xFF1F2937,
      );

  /// Secondary text.
  static Color get muted => _pick(
        brandDark: 0xFFBDB7AB,
        brandLight: 0xFF4F493F,
        classicDark: 0xFFA3A9B3,
        classicLight: 0xFF5B6370,
      );

  /// Labels and the quietest text. Still 4.5:1 everywhere it's used.
  static Color get faint => _pick(
        brandDark: 0xFF968F84,
        brandLight: 0xFF625B4F,
        classicDark: 0xFF9A9EA6,
        classicLight: 0xFF636A75,
      );

  static Color get success => _pick(
        brandDark: 0xFF34D399,
        brandLight: 0xFF126B33,
        classicDark: 0xFF66BB6A,
        classicLight: 0xFF28702C,
      );

  static Color get warning => _pick(
        brandDark: 0xFFFBBF24,
        brandLight: 0xFFA14A07,
        classicDark: 0xFFFFA726,
        classicLight: 0xFFA64A08,
      );

  static Color get danger => _pick(
        brandDark: 0xFFF87171,
        brandLight: 0xFFB91C1C,
        classicDark: 0xFFF47370,
        classicLight: 0xFFC62828,
      );

  /// Color for a passing check. EVOGENCY uses its signal color; Classic's
  /// signal is red, so a pass there has to be green instead.
  static Color get pass => isClassic ? success : signal;

  /// Backdrop behind the centered app frame on wide screens (see
  /// main.dart). In the brand theme the lotus image sits on top of it.
  static Color get backdrop => _pick(
        brandDark: 0xFF0B0A09,
        brandLight: 0xFFE9E2D3,
        classicDark: 0xFF000000,
        classicLight: 0xFFE5E7EB,
      );
}
