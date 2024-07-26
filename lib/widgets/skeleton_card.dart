import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:thinkcard/common/globals.dart' as globals;

class SkeletonCard extends StatelessWidget {

  const SkeletonCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: globals.skeletonDarkColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: globals.skeletonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: globals.skeletonShadowColor,
                  spreadRadius: 12,
                  blurRadius: 24,
                )
              ]
            ),
          )
          .animate(
            onComplete: (controller) {
              controller.repeat();
            },
          ).slideX(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 2500),
            curve: Curves.linear,
            begin: -1.5,
            end: 1.5,
          ),
        ),
      ],
    );
  }
}