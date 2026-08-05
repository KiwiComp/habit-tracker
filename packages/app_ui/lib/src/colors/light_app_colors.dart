import 'dart:ui';
import 'package:app_ui/src/colors/app_colors.dart';

final class LightAppColors extends AppColors {
  const LightAppColors();

  @override
  Brightness get brightness => Brightness.light;

  @override
  Color get seed => const Color(0xFF4F6D3A);

  @override
  Color get primary => const Color(0xFF4F6D3A);
}
