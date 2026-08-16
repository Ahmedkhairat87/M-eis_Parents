import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  final glassTheme = Theme.of(context).extension<LiquidGlassTheme>();
  final isGlassEnabled = glassTheme?.isEnabled ?? false;

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: isGlassEnabled ? Colors.black.withValues(alpha: 0.2) : Colors.black54,
    builder: (context) {
      if (!isGlassEnabled) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: child,
        );
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24.r),
          padding: EdgeInsets.zero,
          child: child,
        ),
      );
    },
  );
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
}) {
  final glassTheme = Theme.of(context).extension<LiquidGlassTheme>();
  final isGlassEnabled = glassTheme?.isEnabled ?? false;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      if (!isGlassEnabled) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: child,
        );
      }

      return GlassContainer(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        padding: EdgeInsets.zero,
        child: child,
      );
    },
  );
}
