// widgets/rive_animation_widget.dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAnimationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: RiveAnimation.asset(
        'assets/cart_animation.riv',
      ),
    );
  }
}
