import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper for pumping a widget inside a themed [MaterialApp].
///
/// Most `app_ui` widgets read design tokens off the [Theme] (via
/// `AppContextExtension`) and the registered [AppExtendedColors] extension,
/// so they need a real [AppTheme] in the tree to build.
extension PumpApp on WidgetTester {
  /// Pumps [widget] under [theme] (light by default), inside a [Scaffold] so
  /// there's a [Material] ancestor for ink/decoration.
  Future<void> pumpApp(
    Widget widget, {
    AppTheme theme = const AppTheme.light(),
  }) {
    return pumpWidget(
      MaterialApp(
        theme: theme.themeData,
        home: Scaffold(body: widget),
      ),
    );
  }
}
