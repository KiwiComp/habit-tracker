import 'dart:ui';
import 'package:app_ui/src/colors/app_colors.dart';

final class DarkAppColors extends AppColors {
  const DarkAppColors();

  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get seed => const Color(0xFF4F6D3A);

  @override
  Color get primary => const Color(0xFFC9DEBA);
}
