import 'package:flutter/widgets.dart';

import 'rendering.dart';

class VerticalStripes extends SingleChildRenderObjectWidget {
  const VerticalStripes({
    required this.numberOfStripes,
    required this.gutter,
    required this.stripe,
    Key? key,
  }) : super(child: stripe, key: key);

  final Widget stripe;
  final int Function(double width) numberOfStripes;
  final double Function(double width) gutter;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderVerticalStripes(
        numberOfStripes: numberOfStripes,
        gutter: gutter,
      );
}

class StripeToBoxAdapter extends SingleChildRenderObjectWidget {
  const StripeToBoxAdapter({required Widget child, Key? key})
      : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderStripeToBoxAdapter();
}

class StripePadding extends SingleChildRenderObjectWidget {
  const StripePadding(
      {required this.stripe,
      required this.leftPadding,
      required this.rightPadding,
      Key? key})
      : super(child: stripe, key: key);

  final Widget stripe;
  final int leftPadding;
  final int rightPadding;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderStripePadding(
        leftPadding: leftPadding,
        rightPadding: rightPadding,
      );

  @override
  void updateRenderObject(
          BuildContext context, covariant RenderStripePadding renderObject) =>
      renderObject
        ..leftPadding = leftPadding
        ..rightPadding = rightPadding;
}
