// Accessibility checks for every screen (added 2026-11-17).
//
// Flutter draws the web app on a canvas, so axe-core can't see inside it.
// These tests are the app's real accessibility gate instead. Each screen
// runs in all four looks (EVOGENCY and Classic, dark and light) against
// Flutter's own guidelines:
// - every tap target is at least 48 by 48 (WCAG 2.2 asks for 24),
// - every tappable thing has a label,
// - all text meets 4.5:1 contrast (3:1 for large text),
// and at 200% text size nothing overflows. Then the behavior checks: a
// failed Calculate moves focus to the field that needs fixing and is read
// out, a result is read out, and headings exist where people expect them.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/screens/ai_screen.dart';
import 'package:frontend/screens/box_fill_screen.dart';
import 'package:frontend/screens/calculators_screen.dart';
import 'package:frontend/screens/circuit_load_screen.dart';
import 'package:frontend/screens/conduit_fill_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/material_screen.dart';
import 'package:frontend/screens/motor_flc_screen.dart';
import 'package:frontend/screens/nec_reference_screen.dart';
import 'package:frontend/screens/ohms_law_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/transformer_sizing_screen.dart';
import 'package:frontend/screens/unit_conversion_screen.dart';
import 'package:frontend/screens/voltage_drop_comparison_screen.dart';
import 'package:frontend/screens/voltage_drop_screen.dart';
import 'package:frontend/screens/wire_ampacity_screen.dart';
import 'package:frontend/settings/app_settings.dart';
import 'package:frontend/theme/app_theme.dart';

final Map<String, Widget Function()> screens = {
  'Home': () => const HomeScreen(),
  'Calculators': () => const CalculatorsScreen(),
  "Ohm's Law": () => const OhmsLawScreen(),
  'Voltage drop': () => const VoltageDropScreen(),
  'Wire ampacity': () => const WireAmpacityScreen(),
  'Box fill': () => const BoxFillScreen(),
  'Conduit fill': () => const ConduitFillScreen(),
  'Circuit load': () => const CircuitLoadScreen(),
  'Motor FLC': () => const MotorFlcScreen(),
  'Transformer sizing': () => const TransformerSizingScreen(),
  'Unit conversion': () => const UnitConversionScreen(),
  'Voltage drop comparison': () => const VoltageDropComparisonScreen(),
  'NEC reference': () => const NecReferenceScreen(),
  'AI assistant': () => const AIScreen(),
  'Material list': () => const MaterialScreen(),
  'Settings': () => const SettingsScreen(),
};

const looks = [
  (AppThemeStyle.kinetic, true, 'EVOGENCY dark'),
  (AppThemeStyle.kinetic, false, 'EVOGENCY light'),
  (AppThemeStyle.classic, true, 'Classic dark'),
  (AppThemeStyle.classic, false, 'Classic light'),
];

/// The screen inside a themed MaterialApp, with reduced motion on so the
/// pulse dot holds still and pumpAndSettle can settle (which also proves
/// the app honors the setting).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  double textScale = 1,
  Size size = const Size(800, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppSettings.isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

/// Records every screen reader announcement the app sends.
List<String> recordAnnouncements(WidgetTester tester) {
  final said = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (message) async {
      final map = message as Map<Object?, Object?>;
      if (map['type'] == 'announce') {
        said.add((map['data'] as Map<Object?, Object?>)['message'] as String);
      }
      return null;
    },
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
  return said;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettings.enableHints.value = true;
  });

  for (final (style, dark, lookName) in looks) {
    group(lookName, () {
      setUp(() {
        AppSettings.themeStyle.value = style;
        AppSettings.isDarkMode.value = dark;
      });

      for (final entry in screens.entries) {
        testWidgets('${entry.key} meets the tap target, label, and contrast guidelines', (tester) async {
          final handle = tester.ensureSemantics();
          await pumpScreen(tester, entry.value());
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    });
  }

  group('200% text on a phone', () {
    setUp(() {
      AppSettings.themeStyle.value = AppThemeStyle.kinetic;
      AppSettings.isDarkMode.value = true;
    });
    for (final entry in screens.entries) {
      testWidgets('${entry.key} lays out without overflow', (tester) async {
        await pumpScreen(tester, entry.value(), textScale: 2, size: const Size(390, 844));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('behavior', () {
    setUp(() {
      AppSettings.themeStyle.value = AppThemeStyle.kinetic;
      AppSettings.isDarkMode.value = true;
    });

    testWidgets('a failed Calculate focuses the first empty field and reads the error', (tester) async {
      final said = recordAnnouncements(tester);
      await pumpScreen(tester, const VoltageDropScreen());
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      final focused = FocusManager.instance.primaryFocus!.context!;
      final field = focused.findAncestorWidgetOfExactType<TextField>()!;
      expect(field.decoration!.labelText, 'Load current (A)');
      expect(said, contains('Enter current, one-way length, and system voltage.'));
    });

    testWidgets('a value that is not a number is marked invalid and focused', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const VoltageDropScreen());
      await tester.enterText(find.widgetWithText(TextField, 'Load current (A)'), 'abc');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a number'), findsOneWidget);
      final node = tester.getSemantics(find.byType(TextField).first);
      expect(node.getSemanticsData().validationResult, SemanticsValidationResult.invalid);
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(focused.findAncestorWidgetOfExactType<TextField>()!.decoration!.labelText, 'Load current (A)');
      handle.dispose();
    });

    testWidgets('a result is read out with its numbers', (tester) async {
      final said = recordAnnouncements(tester);
      await pumpScreen(tester, const WireAmpacityScreen());
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(said.single, startsWith('Result. Allowable ampacity, 25 A.'));
    });

    testWidgets('fields and dropdowns are named by their labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const WireAmpacityScreen());
      expect(find.bySemanticsLabel(RegExp('Wire size')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Material')), findsOneWidget);
      await pumpScreen(tester, const OhmsLawScreen());
      expect(find.bySemanticsLabel(RegExp(r'Voltage \(V\)')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('home has headings and cards read as clean buttons', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const HomeScreen());

      final headings = <String>[];
      void visit(SemanticsNode node) {
        final data = node.getSemanticsData();
        // ignore: deprecated_member_use
        if (data.hasFlag(ui.SemanticsFlag.isHeader)) headings.add(data.label);
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }
      visit(RendererBinding.instance.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
      expect(headings, containsAll(['Electrical math, jobsite ready.', 'The full bench, one surface.']));
      expect(headings, isNot(contains('ElectricalAI Pro, by EVOGENCY')));

      final card = tester.getSemantics(find.bySemanticsLabel(RegExp('^Wire ampacity. Allowable ampacity')));
      expect(card.label, isNot(contains('03')));
      expect(card.label, isNot(contains('AWG ')));
      // ignore: deprecated_member_use
      expect(card.getSemanticsData().hasFlag(ui.SemanticsFlag.isButton), isTrue);
      // The browser moves keyboard focus through this action. Without it a
      // Tab lands on the card but Flutter never draws the focus ring.
      expect(card.getSemanticsData().hasAction(ui.SemanticsAction.focus), isTrue);
      expect(card.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);

      // The EVOGENCY home link only exists in the web build (tests run as
      // the desktop build), so its focus is checked in the browser walk.
      handle.dispose();
    });

    testWidgets('the comparison table exposes rows and cells', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const VoltageDropComparisonScreen());
      await tester.enterText(find.widgetWithText(TextField, 'Load current (A)'), '40');
      await tester.enterText(find.widgetWithText(TextField, 'One-way length (ft)'), '80');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Voltage drop by wire size'), findsOneWidget);
      expect(find.bySemanticsLabel('Within 3%'), findsWidgets);
      handle.dispose();
    });
  });
}
