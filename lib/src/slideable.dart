import 'dart:async';
import 'package:flutter/material.dart';

import 'size_change_notifier.dart';

/// Defines an action button revealed behind the [Slideable] widget when slid.
class ActionItems {
  /// Creates an [ActionItems] configuration.
  ActionItems({
    required this.icon,
    required this.onPress,
    this.backgroudColor = Colors.grey,
    this.radius,
  });

  /// The icon or widget displayed for the action button.
  final Widget icon;

  /// The callback invoked when the action button is tapped.
  final VoidCallback onPress;

  /// The background color of the action button.
  final Color backgroudColor;

  /// The border radius for styling the action button.
  final BorderRadius? radius;
}

/// A widget that reveals underlying [ActionItems] when swiped horizontally.
class Slideable extends StatefulWidget {
  /// Creates a [Slideable] widget.
  const Slideable({
    super.key,
    required this.items,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.resetSlide = true,
    this.duration,
    this.curve,
  }) : assert(
            items.length <= 6, 'A maximum of 6 action items can be provided.');

  /// The list of action buttons (up to 6) revealed when sliding the item.
  final List<ActionItems> items;

  /// The primary child widget displayed on top.
  final Widget child;

  /// The background color of the slideable container.
  final Color backgroundColor;

  /// Whether to automatically reset the slide position when rebuilt.
  final bool resetSlide;

  /// The duration of the slide animation.
  final Duration? duration;

  /// The animation curve applied during sliding.
  final Curve? curve;

  @override
  State<Slideable> createState() => _SlideableState();
}

class _SlideableState extends State<Slideable> {
  final ScrollController controller = ScrollController();

  Size? childSize;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= (widget.items.length * 70.0) / 2 &&
          notification.metrics.pixels < widget.items.length * 70.0) {
        scheduleMicrotask(() {
          controller.animateTo(
            widget.items.length * 60.0,
            duration: widget.duration ?? const Duration(milliseconds: 600),
            curve: widget.curve ?? Curves.decelerate,
          );
        });
      } else if (notification.metrics.pixels > 0.0 &&
          notification.metrics.pixels < (widget.items.length * 70.0) / 2) {
        scheduleMicrotask(() {
          controller.animateTo(
            0.0,
            duration: widget.duration ?? const Duration(milliseconds: 600),
            curve: widget.curve ?? Curves.decelerate,
          );
        });
      }
    }
    return true;
  }

  void _resetSlideSize() {
    if (controller.hasClients) {
      controller.jumpTo(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resetSlide) {
      _resetSlideSize();
    }
    if (childSize == null) {
      return NotificationListener<LayoutSizeChangeNotification>(
        onNotification: (LayoutSizeChangeNotification notification) {
          childSize = notification.newSize;
          scheduleMicrotask(() {
            if (mounted) {
              setState(() {});
            }
          });
          return true;
        },
        child: LayoutSizeChangeNotifier(
          child: widget.child,
        ),
      );
    }

    final List<Widget> above = <Widget>[
      // This is the to be seen widget by default
      Container(
        width: childSize?.width,
        height: childSize?.height,
        color: widget.backgroundColor,
        child: widget.child,
      ),
    ];
    final List<Widget> under = <Widget>[];

    for (final ActionItems item in widget.items) {
      under.add(
        Container(
          alignment: Alignment.center,
          width: 60.0,
          height: childSize?.height,
          decoration: BoxDecoration(
            color: item.backgroudColor,
            borderRadius: item.radius ?? BorderRadius.circular(0),
          ),
          child: item.icon,
        ),
      );

      above.add(
        InkWell(
          onTap: () {
            // This controls the item to flip back...
            controller.jumpTo(2.0);
            item.onPress();
          },
          child: Container(
            alignment: Alignment.center,
            width: 60.0,
            height: childSize?.height,
          ),
        ),
      );
    }

    // Controls the action clickable items
    final Widget items = Container(
      width: childSize?.width,
      height: childSize?.height,
      color: widget.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: under,
      ),
    );

    // This controls how the swipe occurs
    final Widget scrollview = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above,
      ),
    );

    return Stack(
      children: <Widget>[
        items,
        Positioned.fill(
          child: scrollview,
        ),
      ],
    );
  }
}
