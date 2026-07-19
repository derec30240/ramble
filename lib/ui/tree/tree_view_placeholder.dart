import 'package:flutter/material.dart';

import 'package:ramble/ui/l10n/app_localizations.dart';

class TreeViewPlaceholder extends StatelessWidget {
  const TreeViewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(l10n.treePlaceholder),
    );
  }
}
