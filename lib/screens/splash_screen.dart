import 'package:asepe_homes/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _loadingController;
  late AnimationController _circuitController;
  late Animation<double> _floatAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _circuitAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_loadingController);

    _circuitController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _circuitAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(_circuitController);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _loadingController.dispose();
    _circuitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141414), Color(0xFF1F0F5F)],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _circuitAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _circuitAnimation.value,
                    _circuitAnimation.value,
                  ),
                  child: const CircuitBackground(),
                );
              },
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: const SplashIcon(),
                      );
                    },
                  ),

                  SizedBox(height: 40.h),

                  Text(
                    'Asepe Homes',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0F0F0),
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    'Energy Monitoring System',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF1CCE9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 60.h),

                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingDots(animation: _loadingAnimation),
                          SizedBox(width: 15.w),
                          Text(
                            'Initializing...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFFF0F0F0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashIcon extends StatelessWidget {
  const SplashIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1CCE9E), Color(0xFF1F0F5F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(100.w, 100.h),
          painter: PowerSymbolPainter(),
        ),
      ),
    );
  }
}

class PowerSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFF0F0F0)
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    canvas.drawCircle(center, radius, paint);

    paint.style = PaintingStyle.fill;
    final lineRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.5),
      width: 6,
      height: radius * 1.2,
    );
    canvas.drawRect(lineRect, paint);

    final lightningPath =
        Path()
          ..moveTo(center.dx, center.dy - radius * 0.3)
          ..lineTo(center.dx - radius * 0.2, center.dy)
          ..lineTo(center.dx, center.dy)
          ..lineTo(center.dx + radius * 0.2, center.dy + radius * 0.3)
          ..lineTo(center.dx, center.dy + radius * 0.3)
          ..close();

    canvas.drawPath(lightningPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoadingDots extends StatelessWidget {
  final Animation<double> animation;

  const LoadingDots({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = (animation.value - (index * 0.3)) % 1.0;
            final opacity =
                progress < 0.5
                    ? 0.3 + (progress * 1.4)
                    : 1.0 - ((progress - 0.5) * 1.4);
            final scale =
                progress < 0.5
                    ? 0.8 + (progress * 0.8)
                    : 1.2 - ((progress - 0.5) * 0.8);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Transform.scale(
                scale: scale.clamp(0.8, 1.2),
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1CCE9E,
                    ).withValues(alpha: opacity.clamp(0.3, 1.0)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class CircuitBackground extends StatelessWidget {
  const CircuitBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(390.w, 844.h), painter: CircuitPainter());
  }
}

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF1CCE9E).withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;

    const dotSize = 2.0;
    const spacing = 100.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final offsetX = (x * 0.3) % 20;
        final offsetY = (y * 0.7) % 20;

        canvas.drawCircle(Offset(x + offsetX, y + offsetY), dotSize, paint);

        if ((x + y) % 200 == 0) {
          canvas.drawCircle(
            Offset(x + offsetX + 30, y + offsetY + 30),
            1.0,
            paint,
          );
        }
      }
    }

    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF1CCE9E).withValues(alpha: 0.05);

    for (double x = 0; x < size.width; x += 150) {
      canvas.drawLine(Offset(x, 0), Offset(x + 50, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 200) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
