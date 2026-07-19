// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Ramble';

  @override
  String get tabChat => '对话';

  @override
  String get tabTree => '树状视图';

  @override
  String get newSession => '新建会话';

  @override
  String get sessionSettings => '会话设置';

  @override
  String get sessionList => '会话列表';

  @override
  String get appSettings => '软件设置';

  @override
  String get chatPlaceholder => '选择一个会话开始对话';

  @override
  String get treePlaceholder => '树状视图将在会话中展示';
}
