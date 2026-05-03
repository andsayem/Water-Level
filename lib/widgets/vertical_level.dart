import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class VerticalLevel extends StatelessWidget {
  final double y;

  const VerticalLevel({super.key, required this.y});

  @override
  Widget build(BuildContext context) {
    // 1 degree = 5 pixels. Total inner area is ~220px high, bubble is 55px.
    // Center is around 82.5. Max movement is ~80.
    double py = (y * 5).clamp(-80.0, 80.0);
    double bTop = 82.5 + py;

    return Container(
      width: 70,
      height: 260,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF3A3A3A), Color(0xFF0A0A0A)],
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
            width: 30,
            height: double.infinity,
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
            width: 30,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Crosshairs
          Container(
            width: 30,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                bottom: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
              ),
            ),
          ),

          // The Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            top: bTop,
            child: Container(
              width: 24,
              height: 55,
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
                     top: 10,
                     left: 2,
                     child: Container(
                       width: 4,
                       height: 20,
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
            width: 30,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
