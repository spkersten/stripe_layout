import 'package:flutter/widgets.dart';
import 'package:stripe_layout/stripe_layout.dart';

void main() {
  runApp(
    VerticalStripes(
      numberOfStripes: (width) => width < 400 ? 5 : 7,
      gutter: (_) => 10,
      stripe: const StripePadding(
        leftPadding: 1,
        rightPadding: 1,
        stripe: StripeToBoxAdapter(
          child: ColoredBox(
            color: Color(0xffff0000),
          ),
        ),
      ),
    ),
  );
}
