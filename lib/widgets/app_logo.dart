import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/Login.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the original custom logo if image fails to load
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background leaf shape
                  Container(
                    width: size * 0.6,
                    height: size * 0.6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Foreground design - simplified book/leaf icon
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top line
                      Container(
                        width: size * 0.15,
                        height: size * 0.2,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Left leaf
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              width: size * 0.15,
                              height: size * 0.25,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Right leaf
                          Transform.rotate(
                            angle: 0.3,
                            child: Container(
                              width: size * 0.15,
                              height: size * 0.25,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}