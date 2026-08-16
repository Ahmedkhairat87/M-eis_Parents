import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/material.dart';

/// A specialized card for profile sections that supports both single child and multiple children.
class ProfileCard extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final CrossAxisAlignment crossAxisAlignment;

  const ProfileCard({
    super.key,
    this.child,
    this.children,
    this.padding,
    this.margin,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: margin,
      padding: padding,
      child: child ?? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: children ?? [],
      ),
    );
  }
}
