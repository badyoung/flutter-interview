import 'package:flutter/material.dart';

class MRSwipe extends StatefulWidget {
  final List<dynamic> list;
  final double width;
  final Widget? empty;
  final Function(bool, dynamic) onSwipe;
  final Function(double, double) onOpacity;
  final Widget Function(dynamic) builder;

  const MRSwipe(
      {super.key,
      this.empty,
      this.width = 200,
      required this.list,
      required this.onSwipe,
      required this.onOpacity,
      required this.builder});

  @override
  State<MRSwipe> createState() => _MRSwipeState();
}

class _MRSwipeState extends State<MRSwipe> with TickerProviderStateMixin {
  late double _currentValue;
  late double _currentPos;

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(value: 0.5, vsync: this);
    final tween = Tween(begin: -1.0, end: 1.0);
    _animation = tween.animate(_animationController);
    _animationController.addListener(() {
      if (_animationController.value < 0.5) {
        widget.onOpacity((_animation.value.abs() * 3).clamp(0, 1), 0);
      } else {
        widget.onOpacity(0, _animation.value * 5.clamp(0, 1));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _currentValue = _animationController.value;
    _currentPos = details.globalPosition.dx;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    var value = _currentValue +
        (details.globalPosition.dx - _currentPos) / widget.width / 2;
    _animationController.value = value.clamp(0, 1);
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    // final velocity = details.velocity.pixelsPerSecond.dx;

    if (_animationController.value >= .75) {
      _animationController.animateTo(1,
          duration: const Duration(milliseconds: 200));
      await Future.delayed(const Duration(milliseconds: 200));

      widget.onSwipe(false, widget.list.first);
      _animationController.value = .5;
      return;
    }

    if (_animationController.value <= .25) {
      _animationController.animateTo(0,
          duration: const Duration(milliseconds: 200));
      await Future.delayed(const Duration(milliseconds: 200));
      widget.onSwipe(true, widget.list.first);
      _animationController.value = .5;
      return;
    }

    _animationController.animateTo(.5,
        duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (a, b) => GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Center(
                child: widget.list.isEmpty
                    ? widget.empty ??
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          height: MediaQuery.of(context).size.height - 260,
                        )
                    : Stack(
                        clipBehavior: Clip.none,
                        children: widget.list.reversed
                            .map((e1) {
                              return widget.builder(e1);
                            })
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              int index = entry.key;
                              Widget child = entry.value;

                              if (widget.list.length == 1) {
                                return child;
                              } else if (index == widget.list.length - 1) {
                                return buildChild(child);
                              } else if (index == widget.list.length - 2) {
                                return buildSecond(child);
                              } else {
                                return const SizedBox
                                    .shrink(); // Offstage(child: child);
                              }
                            })
                            .toList(),
                      ),
              ),
            ));
  }

  Widget buildChild(child) {
    return Opacity(
      opacity: 1 - _animation.value.abs() / 20,
      child: Transform.rotate(
        origin: const Offset(0, 200),
        alignment: Alignment.bottomCenter,
        angle: _animation.value * 1.2,
        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
      ),
    );
  }

  Widget buildSecond(child) {
    return Transform.scale(
      scale: (.88 + _animation.value.abs() / 2).clamp(0, 1),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }
}
