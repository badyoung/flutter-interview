import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvListWidget extends StatefulWidget {
  final Widget Function(int) itemBuilder;
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;
  final bool autofocus;
  final double? scale;
  final Function(int)? onclick;
  final bool ignoreUp;
  final bool ignoreDown;
  final bool ignoreLeft;
  final bool ignoreRight;
  final int currentIndex;

  const TvListWidget({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.crossAxisCount,
    required this.aspectRatio,
    this.autofocus = false,
    this.onclick,
    this.scale,
    this.ignoreUp = false,
    this.ignoreDown = false,
    this.ignoreLeft = false,
    this.ignoreRight = false,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<TvListWidget> createState() {
    return TvListState();
  }
}

class TvListState extends State<TvListWidget> {
  final FocusNode focusNode = FocusNode();

  int currentIndex = 0;
  bool active = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    focusNode.addListener(() {
      setState(() {
        active = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: widget.autofocus,
      onKey: (node, event) {
        if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (currentIndex % widget.crossAxisCount == 0 &&
                widget.ignoreLeft) {
              return KeyEventResult.ignored;
            }

            if (currentIndex > 0) {
              setState(() {
                currentIndex--;
              });
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (currentIndex % widget.crossAxisCount ==
                    widget.crossAxisCount - 1 &&
                widget.ignoreRight) {
              return KeyEventResult.ignored;
            }
            if (currentIndex < widget.itemCount - 1) {
              setState(() {
                currentIndex++;
              });
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (currentIndex < widget.crossAxisCount && widget.ignoreUp) {
              return KeyEventResult.ignored;
            }

            if (currentIndex >= widget.crossAxisCount) {
              setState(() {
                currentIndex -= widget.crossAxisCount;
              });
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (currentIndex >= widget.itemCount - widget.crossAxisCount &&
                widget.ignoreDown) {
              return KeyEventResult.ignored;
            }

            if (currentIndex < widget.itemCount - widget.crossAxisCount) {
              setState(() {
                currentIndex += widget.crossAxisCount;
              });
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onclick?.call(currentIndex);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: widget.aspectRatio,
        ),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Transform.scale(
              scale:
                  active && currentIndex == index ? 1.0 : widget.scale ?? 0.9,
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: active && currentIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : [],
                    border: active && currentIndex == index
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular((18) + 2)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: widget.itemBuilder(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
