import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/editor/raw_editor/scribble_focusable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // iPad Scribble asks every registered element for its bounds, including one
  // whose render box is attached but not laid out yet: reading its size threw
  // "RenderBox was not laid out".
  testWidgets('bounds of a box that is not laid out yet do not throw', (
    tester,
  ) async {
    final notLaidOut = RenderConstrainedBox(
      additionalConstraints: const BoxConstraints.tightFor(
        width: 10,
        height: 10,
      ),
    )..attach(PipelineOwner());
    addTearDown(notLaidOut.detach);
    expect(notLaidOut.hasSize, isFalse);

    final editorKey = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: ScribbleFocusable(
            editorKey: editorKey,
            renderBoxForBounds: () => notLaidOut,
            onScribbleFocus: (_) {},
            enabled: true,
            scribbleAreaInsets: null,
            child: SizedBox(key: editorKey, width: 100, height: 40),
          ),
        ),
      ),
    );

    final client =
        tester.state(find.byType(ScribbleFocusable)) as ScribbleClient;

    // Falls back to the laid-out element's own size.
    expect(client.bounds, const Rect.fromLTWH(0, 0, 100, 40));
    expect(
      () => client.isInScribbleRect(const Rect.fromLTWH(0, 0, 10, 10)),
      returnsNormally,
    );
  });
}
