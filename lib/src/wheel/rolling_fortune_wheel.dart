part of 'wheel.dart';

/// A fortune wheel visualizes a (random) selection process as a spinning wheel
/// divided into uniformly sized slices, which correspond to the number of
/// [items].
///
/// ![](https://raw.githubusercontent.com/kevlatus/flutter_fortune_wheel/main/images/img-wheel-256.png?sanitize=true)
///
/// See also:
///  * [FortuneBar], which provides an alternative visualization
///  * [FortuneWidget()], which automatically chooses a fitting widget
///  * [Fortune.randomItem], which helps selecting random items from a list
///  * [Fortune.randomDuration], which helps choosing a random duration
class RollingFortuneWheel extends StatefulHookWidget implements FortuneWidget {
  /// The default value for [indicators] on a [FortuneWheel].
  /// Currently uses a single [TriangleIndicator] on [Alignment.topCenter].
  static const List<FortuneIndicator> kDefaultIndicators =
      const <FortuneIndicator>[
    const FortuneIndicator(
      alignment: Alignment.topCenter,
      child: const TriangleIndicator(),
    ),
  ];

  static const StyleStrategy kDefaultStyleStrategy =
      const AlternatingStyleStrategy();

  /// {@macro flutter_fortune_wheel.FortuneWidget.items}
  final List<FortuneItem> items;

  /// {@macro flutter_fortune_wheel.FortuneWidget.selected}
  final int selected;

  /// {@macro flutter_fortune_wheel.FortuneWidget.rotationCount}
  final int rotationCount;

  /// {@macro flutter_fortune_wheel.FortuneWidget.duration}
  final Duration duration;

  /// {@macro flutter_fortune_wheel.FortuneWidget.indicators}
  final List<FortuneIndicator> indicators;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animationType}
  final Curve curve;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
  final VoidCallback onAnimationStart;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
  final VoidCallback onAnimationEnd;

  /// {@macro flutter_fortune_wheel.FortuneWidget.styleStrategy}
  final StyleStrategy styleStrategy;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animateFirst}
  final bool animateFirst;

  /// {@template flutter_fortune_wheel.FortuneWheel}
  /// Creates a new [FortuneWheel] with the given [items], which is centered
  /// on the [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctorArgs}.
  ///
  /// See also:
  ///  * [FortuneBar], which provides an alternative visualization.
  /// {@endtemplate}
  const RollingFortuneWheel({
    Key key,
    @required this.items,
    this.rotationCount = FortuneWidget.kDefaultRotationCount,
    this.selected = 0,
    this.duration = const Duration(seconds: 20),
    this.curve = FortuneCurve.spin,
    this.indicators = kDefaultIndicators,
    this.styleStrategy = kDefaultStyleStrategy,
    this.animateFirst = true,
    this.onAnimationStart,
    this.onAnimationEnd,
  })  : assert(items != null && items.length > 1),
        assert(selected >= 0 && selected < items.length),
        assert(curve != null),
        super(key: key);

  @override
  _RollingFortuneWheelState createState() => _RollingFortuneWheelState();
}

class _RollingFortuneWheelState extends State<RollingFortuneWheel> {
  double startAngle = 0.0;
  double currentAngle = 0.0;

  Duration duration;
  int rotationCount;
  bool running = false;

  _RollingFortuneWheelState();

  double _getAngle(double progress) {
    return 2 * Math.pi * rotationCount * progress;
  }

  @override
  Widget build(BuildContext context) {
    if (duration == null) {
      duration = widget.duration;
    }
    if (rotationCount == null) {
      rotationCount = widget.rotationCount;
    }

    final animationCtrl = useAnimationController(duration: duration);
    final animation =
        CurvedAnimation(parent: animationCtrl, curve: widget.curve);
    final animationBackCtrl =
        useAnimationController(duration: Duration(milliseconds: 400));
    final animationBack =
        CurvedAnimation(parent: animationBackCtrl, curve: Curves.ease);

    Future<void> animate() async {
      if (animationCtrl.isAnimating) {
        return;
      }

      if (widget.onAnimationStart != null) {
        await Future.microtask(widget.onAnimationStart);
      }

      await animationCtrl.forward(from: 0);

      if (widget.onAnimationEnd != null) {
        await Future.microtask(widget.onAnimationEnd);
      }
    }

    useValueChanged(widget.selected, (_, __) async {
      setState(() {
        running = false;
        startAngle = 0;
        currentAngle = 0;
      });
      if (animationCtrl != null) {
        animationCtrl.reset();
      }
    });

    final wheel = AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.rotate(
          angle: running
              ? -2 * Math.pi * (widget.selected / widget.items.length)
              : 0,
          child: Transform.rotate(
            angle: _getAngle(animation.value),
            child: SizedBox.expand(
              child: _SlicedCircle(
                items: widget.items,
                styleStrategy: widget.styleStrategy,
              ),
            ),
          ),
        );
      },
    );

    final startWheel = LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanEnd: (details) async {
          double velocity = details.velocity.pixelsPerSecond.distance;
          /*
          print('Start Angle = ${startAngle}');
          print('End Angle = ${currentAngle}');
          print('Velocity ${velocity}');
          */
          if (velocity > 500) {
            if (!running) {
              setState(() {
                running = true;
                rotationCount =
                    details.velocity.pixelsPerSecond.distance ~/ 150;
                duration = Duration(seconds: rotationCount ~/ 2);
              });

              print(
                  'Velocity ${velocity} : Duration ${duration} / ${rotationCount} - Selected = ${widget.selected}');

              await animate();
            }
          } else {
            animationBackCtrl.reset();
            animationBackCtrl.forward(from: 0).whenComplete(() {
              setState(() {
                startAngle = currentAngle;
              });
            });
          }
        },
        onPanStart: (details) {
          Offset centerOfGestureDetector =
              Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          final touchPositionFromCenter =
              details.localPosition - centerOfGestureDetector;
          startAngle = touchPositionFromCenter.direction * 180 / Math.pi;
        },
        onPanUpdate: (details) {
          Offset centerOfGestureDetector =
              Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          final touchPositionFromCenter =
              details.localPosition - centerOfGestureDetector;
          setState(() {
            currentAngle = touchPositionFromCenter.direction * 180 / Math.pi;
            // print('Angle = ${currentAngle - startAngle}');
          });
        },
        child: AnimatedBuilder(
            animation: animationBack,
            builder: (context, _) {
              return Transform.rotate(
                  angle: !running
                      ? (animationBackCtrl.isAnimating
                              ? 1 - animationBack.value
                              : 1) *
                          ((currentAngle - startAngle) * Math.pi / 180)
                      : 0,
                  child: wheel);
            }),
      );
    });

    return Stack(
      children: [
        startWheel,
        for (var it in widget.indicators) _WheelIndicator(indicator: it),
      ],
    );
  }
}
