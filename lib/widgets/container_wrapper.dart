import 'package:flutter/material.dart';
import 'package:furcare_app/utils/const/app_constants.dart';

class ContainerWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;

  const ContainerWrapper({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.defaultBorderRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
