import 'package:eism/ui/login_screen/widgets/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileIconBox extends StatelessWidget {
  final AppProfile profile;
  final bool isExpanding;

  const ProfileIconBox({
    super.key,
    required this.profile,
    this.isExpanding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: profile.color,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: profile.color.withAlpha((0.3 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              return Center(
                child: profile.isParent 
                  ? Icon(
                      Icons.person_pin_rounded,
                      color: Colors.white,
                      size: size * 0.6,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: size * 0.1,
                              height: size * 0.1,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: size * 0.25),
                            Container(
                              width: size * 0.1,
                              height: size * 0.1,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size * 0.12),
                        CustomPaint(
                          size: Size(size * 0.45, size * 0.15),
                          painter: SmilePainter(),
                        ),
                      ],
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.3,
      size.width,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
