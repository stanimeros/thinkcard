import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonChat extends StatelessWidget {
  final double height;

  const SkeletonChat({
    super.key,
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    //TODO
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.8),
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
        duration: const Duration(milliseconds: 2500),
        curve: Curves.linear,
        begin: -1.5,
        end: 1.5,
      ),
    );
  }
}