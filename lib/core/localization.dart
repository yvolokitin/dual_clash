import 'package:flutter/material.dart';
import 'package:dual_clash/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

AppLocalizations? appLocalizations() {
  final context = appNavigatorKey.currentContext;
  if (context == null) {
    return null;
  }
  return AppLocalizations.of(context);
}

String aiBeltName(AppLocalizations l10n, int level) {
  switch (level) {
    case 1:
      return l10n.aiBeltWhite;
    case 2:
      return l10n.aiBeltYellow;
    case 3:
      return l10n.aiBeltOrange;
    case 4:
      return l10n.aiBeltGreen;
    case 5:
      return l10n.aiBeltBlue;
    case 6:
      return l10n.aiBeltBrown;
    case 7:
      return l10n.aiBeltBlack;
    default:
      return l10n.aiBeltBlack;
  }
}

String formatDurationShort(AppLocalizations l10n, int ms) {
  if (ms <= 0) {
    return l10n.durationSeconds(0);
  }
  int seconds = (ms / 1000).floor();
  final hours = seconds ~/ 3600;
  seconds %= 3600;
  final minutes = seconds ~/ 60;
  seconds %= 60;
  if (hours > 0) {
    return l10n.durationHoursMinutes(hours, minutes);
  }
  if (minutes > 0) {
    return l10n.durationMinutesSeconds(minutes, seconds);
  }
  return l10n.durationSeconds(seconds);
}
