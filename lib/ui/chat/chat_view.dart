import 'package:flutter/material.dart';

import 'package:ramble/ui/l10n/app_localizations.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(l10n.chatPlaceholder),
    );
  }
}
