import 'package:flutter/material.dart';
import 'package:flutter_quill/src/editor/widgets/text/text_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The drag-offset listener updates the magnifier in a post-frame callback;
  // when the detector was removed before that frame, it read `context` of an
  // unmounted State ("Null check operator used on a null value").
  testWidgets(
    'a drag offset change followed by the detector leaving the tree does not throw',
    (tester) async {
      final dragOffset = ValueNotifier<Offset?>(null);
      addTearDown(dragOffset.dispose);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: EditorTextSelectionGestureDetector(
            dragOffsetNotifier: dragOffset,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      // The listener schedules its callback; the same frame removes the detector.
      dragOffset.value = const Offset(10, 10);
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    },
  );
}
