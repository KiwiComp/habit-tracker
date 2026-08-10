import 'package:flutter/widgets.dart';
import 'package:habit_tracker/l10n/gen/app_localizations.dart';

export 'package:habit_tracker/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  Locale get locale => Localizations.localeOf(this);
}
