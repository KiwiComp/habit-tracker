import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/start_page/widgets/slide_to_reveal_tile.dart';

import '../../helpers/helpers.dart';

const _revealWidth = 80.0;
const _rowWidth = 300.0;
const _childKey = Key('slide-child');
const _actionKey = Key('slide-action');

/// Mirrors how `ScheduleList` drives the tile: the parent owns "which row is
/// open" and feeds it back in through `isDesignatedOpen`, so the widget can
/// be forced shut from outside. [_HarnessState.setDesignated] is the "another
/// row just opened" lever.
class _Harness extends StatefulWidget {
  const _Harness({this.onOpenChanged, this.onFraction});

  final ValueChanged<bool>? onOpenChanged;
  final ValueChanged<double>? onFraction;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _designated = false;

  void setDesignated({required bool open}) =>
      setState(() => _designated = open);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: _rowWidth,
          child: SlideToRevealTile(
            revealWidth: _revealWidth,
            isDesignatedOpen: _designated,
            onOpenChanged: (open) {
              widget.onOpenChanged?.call(open);
              setDesignated(open: open);
            },
            action: const SizedBox(key: _actionKey),
            childBuilder: (context, revealFraction) {
              widget.onFraction?.call(revealFraction);
              return Container(
                key: _childKey,
                height: 56,
                width: double.infinity,
                color: const Color(0xFF2196F3),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  double childWidth(WidgetTester tester) =>
      tester.getSize(find.byKey(_childKey)).width;

  double childLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(_childKey)).dx;

  _HarnessState harness(WidgetTester tester) =>
      tester.state<_HarnessState>(find.byType(_Harness));

  group('SlideToRevealTile', () {
    testWidgets('starts closed, with the child at full width', (tester) async {
      await tester.pumpApp(const _Harness());

      expect(childWidth(tester), moreOrLessEquals(_rowWidth));
    });

    testWidgets('a drag past the halfway point settles open', (tester) async {
      await tester.pumpApp(const _Harness());

      await tester.drag(find.byKey(_childKey), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(childWidth(tester), moreOrLessEquals(_rowWidth - _revealWidth));
    });

    testWidgets('a drag short of the halfway point snaps back closed', (
      tester,
    ) async {
      await tester.pumpApp(const _Harness());

      await tester.drag(find.byKey(_childKey), const Offset(-25, 0));
      await tester.pumpAndSettle();

      expect(childWidth(tester), moreOrLessEquals(_rowWidth));
    });

    testWidgets('the child shrinks from the right; its left edge never moves', (
      tester,
    ) async {
      await tester.pumpApp(const _Harness());
      final leftWhenClosed = childLeft(tester);

      await tester.drag(find.byKey(_childKey), const Offset(-200, 0));
      await tester.pumpAndSettle();

      // The whole point of this widget over a translate-based slide: the row
      // gets narrower by exactly the reveal width, it doesn't move sideways.
      expect(childLeft(tester), moreOrLessEquals(leftWhenClosed));
      expect(childWidth(tester), moreOrLessEquals(_rowWidth - _revealWidth));
    });

    testWidgets('reports the settled state through onOpenChanged', (
      tester,
    ) async {
      final reported = <bool>[];
      await tester.pumpApp(_Harness(onOpenChanged: reported.add));

      await tester.drag(find.byKey(_childKey), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(reported, [true]);

      await tester.drag(find.byKey(_childKey), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(reported, [true, false]);
    });

    testWidgets('closes when the parent withdraws isDesignatedOpen', (
      tester,
    ) async {
      await tester.pumpApp(const _Harness());

      await tester.drag(find.byKey(_childKey), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(childWidth(tester), moreOrLessEquals(_rowWidth - _revealWidth));

      // Stands in for another row being opened.
      harness(tester).setDesignated(open: false);
      await tester.pumpAndSettle();

      expect(childWidth(tester), moreOrLessEquals(_rowWidth));
    });

    testWidgets('passes the current reveal fraction to childBuilder', (
      tester,
    ) async {
      final fractions = <double>[];
      await tester.pumpApp(_Harness(onFraction: fractions.add));

      expect(fractions.last, 0);

      await tester.drag(find.byKey(_childKey), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(fractions.last, 1);

      // Mid-close the builder sees an intermediate value, not just the two
      // endpoints — that's what lets the tile square off its corners as it
      // animates rather than snapping between two states.
      harness(tester).setDesignated(open: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(fractions.last, greaterThan(0));
      expect(fractions.last, lessThan(1));

      await tester.pumpAndSettle();
      expect(fractions.last, 0);
    });
  });
}
