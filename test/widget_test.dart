import 'package:flutter_test/flutter_test.dart';

import 'package:ramble/main.dart';

void main() {
  testWidgets('App shell renders with tabs and drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RambleApp());

    expect(find.text('Ramble'), findsWidgets);
    expect(find.text('对话'), findsOneWidget);
    expect(find.text('树状视图'), findsOneWidget);
  });
}
