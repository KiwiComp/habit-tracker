import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps the widget built by [childBuilder] in a horizontal-drag gesture
/// that shrinks it from the right — its left edge stays put — revealing
/// [action] underneath in the space that opens up, instead of the child
/// sliding out of frame.
///
/// A row's own `Slidable`-style "swipe to reveal" is usually done by
/// translating the row sideways (that's what `package:flutter_slidable`
/// does under the hood — see its `Slidable.build`, which always wraps its
/// child in a `SlideTransition`). There's no built-in widget for the
/// shrink-in-place variant, so this drives it directly off an
/// [AnimationController]: the controller's value (0 = closed, 1 = fully
/// open) is set straight from drag deltas while dragging, then animated to
/// whichever end is closer once the drag ends.
///
/// Deliberately knows nothing about what it wraps — it lives in its own
/// file because it's an interaction primitive that changes for different
/// reasons than the habit row it currently wraps, not because it's reused
/// yet. It is not exported from `widgets.dart` for that reason: it isn't a
/// "start page widget", it's just currently only used by one.
class SlideToRevealTile extends StatefulWidget {
  /// Creates a [SlideToRevealTile].
  const SlideToRevealTile({
    required this.revealWidth,
    required this.action,
    required this.childBuilder,
    required this.isDesignatedOpen,
    required this.onOpenChanged,
    super.key,
  });

  /// How far the child can shrink, in logical pixels — also [action]'s
  /// width.
  final double revealWidth;

  /// Revealed underneath the child as it shrinks.
  ///
  /// While closed this is fully covered by the child (which paints above
  /// it), so it can't be hit-tested until the row is open — worth knowing
  /// when driving this in a test.
  final Widget action;

  /// Builds the row content that shrinks to reveal [action], given how far
  /// open it currently is (0 closed, 1 fully open) — a builder rather than
  /// a plain [Widget] so the content itself can react to the reveal
  /// progress (e.g. squaring off its corners as it opens), even though the
  /// [AnimationController] driving it lives inside this widget's state,
  /// not wherever the content is constructed.
  final Widget Function(BuildContext context, double revealFraction)
  childBuilder;

  /// Whether the parent still wants this row open. Set to `false` (e.g.
  /// because another row just opened) to force this one shut, even if it
  /// was mid-drag or already settled open.
  final bool isDesignatedOpen;

  /// Called once a drag settles, reporting whether this row ended up open
  /// or closed — lets the parent track which single row is open.
  final ValueChanged<bool> onOpenChanged;

  @override
  State<SlideToRevealTile> createState() => _SlideToRevealTileState();
}

class _SlideToRevealTileState extends State<SlideToRevealTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = (details.primaryDelta ?? 0) / widget.revealWidth;
    // Dragging left is a negative delta; subtracting it opens the tile.
    _controller.value = (_controller.value - delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final open = _controller.value > 0.5;
    unawaited(_controller.animateTo(open ? 1 : 0, curve: Curves.easeOut));
    widget.onOpenChanged(open);
  }

  @override
  void didUpdateWidget(covariant SlideToRevealTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another row became the designated-open one — close this one even if
    // it was mid-drag or already settled open.
    //
    // Only the true -> false transition is handled: `isDesignatedOpen` is
    // never synced on init, so a row scrolled out of the list's cache and
    // back comes back visually closed while the parent still records it as
    // open. Harmless today (re-dragging it settles the two back in step),
    // but don't start seeding `_controller` from `isDesignatedOpen` in
    // `initState` without reconciling that here too.
    if (oldWidget.isDesignatedOpen && !widget.isDesignatedOpen) {
      unawaited(_controller.animateTo(0, curve: Curves.easeOut));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        // Rebuilt every tick rather than passed as AnimatedBuilder's usual
        // static `child:` — the content itself now depends on the animated
        // value (see `childBuilder`'s doc comment), so it can't be built
        // once and reused across frames like `action` is.
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: widget.revealWidth,
                child: widget.action,
              ),
              // The only non-Positioned child, so it sets the Stack's size
              // — shrinking its right inset is what makes the tile itself
              // shrink rather than translate, while its left edge (the
              // Stack's own left edge) never moves.
              //
              // Painted last, so while closed it sits above `action` and
              // absorbs hit tests aimed at it.
              Padding(
                padding: EdgeInsets.only(
                  right: _controller.value * widget.revealWidth,
                ),
                child: widget.childBuilder(context, _controller.value),
              ),
            ],
          );
        },
      ),
    );
  }
}
