import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic();
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pumpEditor(WidgetTester tester, String placeholder) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(placeholder: placeholder),
          ),
        ),
      );

  // The placeholder used to be spliced into a JSON string, so a line break or
  // a backslash in it made jsonDecode throw while building the editor.
  testWidgets(
    'shows a placeholder with a line break, a quote and a backslash',
    (tester) async {
      const placeholder = 'Reward for Completion 🎁\nSay "done" \\ then rest';

      await pumpEditor(tester, placeholder);

      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Reward for Completion', findRichText: true),
        findsOneWidget,
      );
      // The placeholder is display-only: the document stays empty.
      expect(controller.document.isEmpty(), isTrue);
    },
  );

  testWidgets('keeps the first line block attributes under the placeholder', (
    tester,
  ) async {
    controller.formatSelection(Attribute.ul);

    await pumpEditor(tester, 'List\nitem');

    expect(tester.takeException(), isNull);
    expect(find.textContaining('List', findRichText: true), findsOneWidget);
  });
}
