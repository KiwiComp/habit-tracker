/// Corner radius values following the Material 3 shape scale.
///
/// See: https://m3.material.io/styles/shape/shape-scale-tokens
class AppRadius {
  /// Creates an [AppRadius].
  const AppRadius();

  /// 0. Material's "none" shape token.
  double get none => 0;

  /// 4. Material's "extra small" shape token.
  double get xs => 4;

  /// 8. Material's "small" shape token.
  double get sm => 8;

  /// 12. Material's "medium" shape token.
  double get md => 12;

  /// 16. Material's "large" shape token.
  double get lg => 16;

  /// 28. Material's "extra large" shape token.
  double get xl => 28;

  /// 36. Custom radius.
  double get xxl => 36;

  /// 999. Fully rounded (pill / stadium) shape.
  double get full => 999;
}
