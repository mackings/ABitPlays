import 'package:flutter/material.dart';

class IntroButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final Color color2;
  final double radius;

  const IntroButton(
      {Key key,
      this.onPressed,
      this.radius,
      this.color2,
      this.color,
      @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
        child: child,
      ),
//      shape: Border.all(width:10.0,  color:  Colors.white, style: BorderStyle.solid),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: color2, style: BorderStyle.solid),
      ),
    );
  }
}
