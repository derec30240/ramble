// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ramble';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabTree => 'Tree View';

  @override
  String get newSession => 'New Session';

  @override
  String get sessionSettings => 'Session Settings';

  @override
  String get sessionList => 'Session List';

  @override
  String get appSettings => 'App Settings';

  @override
  String get chatPlaceholder => 'Select a session to start chatting';

  @override
  String get treePlaceholder => 'Tree view will be shown in a session';
}
