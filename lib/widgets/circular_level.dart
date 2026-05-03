import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_colors.dart';

class CircularLevel extends StatelessWidget {
  final double x;
  final double y;

  const CircularLevel({
    super.key,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    // Math to clamp bubble within the circle
    final maxRadius = 105.0; // Inner circle radius (120) - Bubble radius (15)
    
    // Scale degrees to pixels. 1 degree = 5 pixels 
    double px = x * 5;
    double py = y * 5;
    
    double distance = sqrt(px * px + py * py);
    if (distance > maxRadius) {
       px = px * (maxRadius / distance);
       py = py * (maxRadius / distance);
    }
    
    // Center point of the 280x280 stack is 140.
    // Top left position of 30x30 bubble = 140 + px - 15, 140 + py - 15
    double bLeft = 140 + px - 15;
    double bTop = 140 + py - 15;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Metallic outer rim
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3A3A3A),
            Color(0xFF0A0A0A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(10, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// INNER LIQUID BACKGROUND
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Dark greenish back
              color: const Color(0xFF0F1A0F),
              boxShadow: [
                // Inner Shadow simulation
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                  offset: const Offset(0, 0),
                )
              ],
            ),
          ),
          
          /// NEON GREEN LIQUID SURFACE
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.6, 0.9, 1.0],
              ),
            ),
          ),

          /// CROSSHAIRS
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 240,
            color: AppColors.primary.withOpacity(0.3),
          ),
          Container(
            width: 240,
            height: 1,
            color: AppColors.primary.withOpacity(0.3),
          ),

          /// BUBBLE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            left: bLeft,
            top: bTop,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Bubble should look like a hollow pocket in the liquid
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                ),
                boxShadow: [
                   BoxShadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  // Dark drop shadow
                   BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                  )
                ],
              ),
              child: Stack(
                children: [
                   // Specular highlight on bubble
                   Positioned(
                     top: 4,
                     left: 6,
                     child: Container(
                       width: 8,
                       height: 4,
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.8),
                         borderRadius: BorderRadius.circular(10),
                       ),
                     ),
                   )
                ],
              ),
            ),
          ),
          
          /// TOP GLASS REFLECTION DOME
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.5),
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),

        ],
      ),
    ).animate().fade(duration: 500.ms);
  }
}