import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class HorizontalLevel extends StatelessWidget {
  final double x;

  const HorizontalLevel({super.key, required this.x});

  @override
  Widget build(BuildContext context) {
    // 1 degree = 5 pixels. Total inner area is ~260px wide, bubble is 55px.
    // Center is around 102.5. Max movement is ~100.
    double px = (x * 5).clamp(-100.0, 100.0);
    double bLeft = 102.5 + px;

    return Container(
      width: 300,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // Outer metallic chassis
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF0A0A0A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner tube (Liquid Background)
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF0F1A0F),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: -2,
                )
              ],
            ),
          ),

          // Neon liquid layer
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Crosshairs
          Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                right: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
              ),
            ),
          ),

          // The Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            left: bLeft,
            child: Container(
              width: 55,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.7),
                    AppColors.primary,
                  ],
                  radius: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                   // Specular highlight
                   Positioned(
                     top: 2,
                     left: 10,
                     child: Container(
                       width: 20,
                       height: 4,
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.7),
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                   )
                ],
              ),
            ),
          ),

          // Top glass reflection over the tube
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
