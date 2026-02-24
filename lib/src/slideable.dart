import 'dart:async';
import 'package:flutter/material.dart';

import 'size_change_notifier.dart';

class ActionItems extends Object {
  ActionItems({
    required this.icon,
    required this.onPress,
    this.backgroudColor = Colors.grey,
    this.radius,
  });

  final Widget icon;
  final VoidCallback onPress;
  final Color backgroudColor;
  final BorderRadius? radius;
}

// typedef IndexRetriever = void Function(int index);
// typedef void IndexRetriever(int index);

class Slideable extends StatefulWidget {
  Slideable({
    Key? key,
    required this.items,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.resetSlide = true,
    this.duration,
    this.curve,
  }) : super(key: key) {
    assert(items.length <= 6);
  }

  final List<ActionItems> items;
  final Widget child;
  final Color backgroundColor;
  final bool resetSlide;
  final Duration? duration;
  final Curve? curve;

  @override
  State<StatefulWidget> createState() => _SlideableState();
}

class _SlideableState extends State<Slideable> {
  ScrollController controller = ScrollController();

  Size? childSize;

  bool _handleScrollNotification(dynamic notification) {
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

  _resetSlideSize() {
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
      return NotificationListener(
        child: LayoutSizeChangeNotifier(
          child: widget.child,
        ),
        onNotification: (LayoutSizeChangeNotification notification) {
          childSize = notification.newSize;
          scheduleMicrotask(() {
            setState(() {});
          });
          return true;
        },
      );
    }

    List<Widget> above = <Widget>[
      // This is the to be seen widget by default
      Container(
        width: childSize?.width,
        height: childSize?.height,
        color: widget.backgroundColor,
        child: widget.child,
      ),
    ];
    List<Widget> under = <Widget>[];

    for (ActionItems item in widget.items) {
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
          child: Container(
            alignment: Alignment.center,
            width: 60.0,
            height: childSize?.height,
          ),
          onTap: () {
            // This controlls the item to flip back...
            controller.jumpTo(2.0);
            item.onPress();
          },
        ),
      );
    }

    // Controls the action clickable items
    Widget items = Container(
      width: childSize?.width,
      height: childSize?.height,
      color: widget.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: under,
      ),
    );

    // This controls how the swip occurs
    Widget scrollview = NotificationListener(
      child: ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above,
      ),
      onNotification: _handleScrollNotification,
    );

    return Stack(
      children: <Widget>[
        items,
        Positioned(
          child: scrollview,
          left: 0.0,
          bottom: 0.0,
          right: 0.0,
          top: 0.0,
        )
      ],
    );
  }
}
