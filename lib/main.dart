import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Springy Button',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Springy Button')),
      body: SpringyButton(
        width: 50,
        height: 50,
        direction: Direction.verticalUp,
        action: () async => await toDoAction(),
      ),
    );
  }

  Future<void> toDoAction() async {
    await Future.delayed(
      const Duration(milliseconds: 250),
      // ignore: avoid_print
      () => print('what to do!'),
    );
  }
}

enum Direction {
  verticalUp,
  verticalDown,
  horizentalRight,
  horizentalLeft
}

// ignore: must_be_immutable
class SpringyButton extends StatefulWidget {
  double width;
  double height;
  Direction direction;
  VoidCallback? action;
  Widget? child;
  double? distance;
  Color? bgColor;
  Duration? duration;
  Curve? forwardCurve;
  Curve? backwardCurve;

  // ignore: use_key_in_widget_constructors
  SpringyButton({
    Key? key,
    required this.width,
    required this.height,
    required this.direction,
    this.action,
    this.child,
    this.distance,
    this.bgColor,
    this.duration,
    this.forwardCurve,
    this.backwardCurve,
  }) {
    assert(duration == null || duration is Duration);
    assert(distance == null || distance is num);
    assert(bgColor == null || bgColor is Color);
    assert(forwardCurve == null || forwardCurve is Curve);
    assert(backwardCurve == null || backwardCurve is Curve);
    // ------------------------------------------------------
    action = action ?? () {};
    duration = duration ?? const Duration(milliseconds: 700);
    distance = distance ?? 50.0;
    bgColor = bgColor ?? Colors.redAccent;
    forwardCurve = forwardCurve ?? Curves.elasticOut;
    backwardCurve = backwardCurve ?? Curves.easeInBack;
  }

  @override
  State<SpringyButton> createState() => _SpringyButtonState();
}

class _SpringyButtonState extends State<SpringyButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> offsetForward;
  late Animation<double> offsetBackward;
  late double c;

  @override
  void initState() {
    super.initState();
    c = widget.direction == Direction.verticalUp || widget.direction == Direction.horizentalLeft ? -1 : 1;
    _controller = AnimationController(duration: widget.duration, vsync: this);

    offsetForward = Tween<double>(
      begin: 0.0,
      end: c * widget.distance!,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.7,
          curve: widget.forwardCurve!,
        ),
      ),
    );

    offsetBackward = Tween<double>(
      begin: c * widget.distance!,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.7,
          1.0,
          curve: widget.backwardCurve!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    // ignore: avoid_print
    print('play animation!'); // NOTE: dont remove this. becouse
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    } finally {
      _controller.reset();
    }
    widget.action!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (DragEndDetails details) async {
        switch (widget.direction) {
          case Direction.verticalDown:
            if (details.velocity.pixelsPerSecond.dy.toDouble() > 50.0) await _playAnimation();
            break;
          case Direction.verticalUp:
            if (details.velocity.pixelsPerSecond.dy.toDouble() < -50.0) await _playAnimation();
            break;
          case Direction.horizentalRight:
            if (details.velocity.pixelsPerSecond.dx.toDouble() > 50.0) await _playAnimation();
            break;
          default:
            if (details.velocity.pixelsPerSecond.dx.toDouble() < -50.0) await _playAnimation();
        }
      },
      child: AnimatedBuilder(
        builder: (context, child) {
          final offsetValue = offsetForward.value + offsetBackward.value - c * widget.distance!;
          Offset offset;
          if (widget.direction == Direction.verticalDown || widget.direction == Direction.verticalUp) {
            offset = Offset(0, offsetValue);
          } else {
            offset = Offset(offsetValue, 0);
          }
          return Transform.translate(
            offset: offset,
            child: Center(
              child: Container(
                width: widget.width,
                height: widget.height,
                color: widget.bgColor,
                child: widget.child,
              ),
            ),
          );
        },
        animation: _controller.view,
      ),
    );
  }
}
