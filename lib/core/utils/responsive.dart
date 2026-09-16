import 'package:flutter/material.dart';

enum ResponsiveType { mobile, tablet, desktop }

class Responsive {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ResponsiveType getType(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) {
      return ResponsiveType.mobile;
    } else if (width < tabletMax) {
      return ResponsiveType.tablet;
    } else {
      return ResponsiveType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMax;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMax;

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    double width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMax && desktop != null) {
      return desktop;
    }
    if (width >= mobileMax && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveType type) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ResponsiveType type;
        if (constraints.maxWidth < Responsive.mobileMax) {
          type = ResponsiveType.mobile;
        } else if (constraints.maxWidth < Responsive.tabletMax) {
          type = ResponsiveType.tablet;
        } else {
          type = ResponsiveType.desktop;
        }
        return builder(context, type);
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
