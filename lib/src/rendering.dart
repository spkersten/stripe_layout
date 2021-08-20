import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

@immutable
class StripeConstraints extends Constraints {
  const StripeConstraints({
    required this.gutter,
    required this.minN,
    required this.maxN,
    required this.minHeight,
    required this.maxHeight,
    required this.stripeWidth,
  });

  final double gutter;
  final int minN;
  final int maxN;
  final double stripeWidth;
  final double minHeight;
  final double maxHeight;

  BoxConstraints get asBoxConstraints => BoxConstraints(
        minWidth: minN * stripeWidth + (minN - 1) * gutter,
        maxWidth: maxN * stripeWidth + (maxN - 1) * gutter,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );

  StripeConstraints copyWith({
    double? gutter,
    int? minN,
    int? maxN,
    double? stripeWidth,
    double? minHeight,
    double? maxHeight,
  }) =>
      StripeConstraints(
        gutter: gutter ?? this.gutter,
        minN: minN ?? this.minN,
        maxN: maxN ?? this.maxN,
        stripeWidth: stripeWidth ?? this.stripeWidth,
        minHeight: minHeight ?? this.minHeight,
        maxHeight: maxHeight ?? this.maxHeight,
      );

  StripeConstraints tightenFor({required int N}) => copyWith(
        minN: N.clamp(minN, maxN),
        maxN: N.clamp(minN, maxN),
      );

  @override
  bool get isTight => minN == maxN && minHeight == maxHeight;

  @override
  bool get isNormalized =>
      gutter >= 0 &&
      minN > 0 &&
      minN <= maxN &&
      minHeight >= 0.0 &&
      minHeight <= maxHeight;
}

class StripeSize {
  const StripeSize(this.N, this.height);

  static const StripeSize zero = StripeSize(0, 0);

  final int N;
  final double height;

  Size asBox(StripeConstraints constraints) {
    return Size(
      N * constraints.stripeWidth + (N - 1) * constraints.gutter,
      height,
    );
  }
}

class RenderVerticalStripes extends RenderBox
    with RenderObjectWithChildMixin<RenderStripe> {
  RenderVerticalStripes({
    required int Function(double width) numberOfStripes,
    required double Function(double width) gutter,
  })  : _numberOfStripes = numberOfStripes,
        _gutter = gutter;

  int Function(double width) _numberOfStripes;

  set numberOfStripes(int Function(double width) value) {
    if (value != _numberOfStripes) {
      _numberOfStripes = value;
      markNeedsLayout();
    }
  }

  double Function(double width) _gutter;

  set gutter(double Function(double width) value) {
    if (value != _gutter) {
      _gutter = value;
      markNeedsLayout();
    }
  }

  StripeConstraints get stripeConstraints {
    final N = _numberOfStripes(constraints.maxWidth);
    final gutter = _gutter(constraints.maxWidth);
    return StripeConstraints(
      gutter: gutter,
      minN: N,
      maxN: N,
      minHeight: constraints.maxHeight,
      maxHeight: constraints.maxHeight,
      stripeWidth: (constraints.maxWidth - gutter * (N - 1)) / N,
    );
  }

  @override
  void performLayout() {
    child!.layout(stripeConstraints, parentUsesSize: false);
    size = Size(constraints.maxWidth, child!.size.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final N = stripeConstraints.maxN;
      final gutter = stripeConstraints.gutter;
      final stripeWidth = stripeConstraints.stripeWidth;
      for (var gutterIndex = 0; gutterIndex < N - 1; gutterIndex++) {
        final rect = (offset +
                Offset(stripeWidth + gutterIndex * (stripeWidth + gutter), 0)) &
            Size(gutter, size.height);
        context.canvas.drawRect(rect, Paint()..color = const Color(0x8000ff00));
      }
      return true;
    }());
  }
}

abstract class RenderStripe extends RenderObject {
  StripeSize? _size;

  StripeSize get size => _size!;

  set size(StripeSize value) {
    _size = value;
  }

  @override
  StripeConstraints get constraints => super.constraints as StripeConstraints;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  @override
  void debugAssertDoesMeetConstraints() {
    // TODO: implement debugAssertDoesMeetConstraints
  }

  @override
  Rect get paintBounds => Offset.zero & size.asBox(constraints);

  @override
  void performLayout() {
    throw UnimplementedError();
  }

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => paintBounds;
}

class RenderStripeToBoxAdapter extends RenderStripe
    with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    child!.layout(constraints.tightenFor(N: constraints.maxN).asBoxConstraints,
        parentUsesSize: true);
    size = StripeSize(
      constraints.maxN,
      child!.size.height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}

class RenderStripePadding extends RenderStripe
    with RenderObjectWithChildMixin<RenderStripe> {
  RenderStripePadding({required int leftPadding, required int rightPadding})
      : _leftPadding = leftPadding,
        _rightPadding = rightPadding;

  int _leftPadding;

  int get leftPadding => _leftPadding;

  set leftPadding(int value) {
    if (value != _leftPadding) {
      _leftPadding = value;
      markNeedsLayout();
    }
  }

  int _rightPadding;

  int get rightPadding => _rightPadding;

  set rightPadding(int value) {
    if (value != _rightPadding) {
      _rightPadding = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final childConstraints = constraints.copyWith(
      minN: constraints.minN - leftPadding - rightPadding,
      maxN: constraints.maxN - leftPadding - rightPadding,
    );
    child!.layout(childConstraints, parentUsesSize: true);
    final parentData = child!.parentData as BoxParentData;
    parentData.offset = Offset(
      leftPadding * (constraints.stripeWidth + constraints.gutter),
      0,
    );
    size = StripeSize(
      child!.size.N + 2,
      child!.size.height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final parentData = child!.parentData as BoxParentData;
    context.paintChild(child!, offset + parentData.offset);
  }
}
