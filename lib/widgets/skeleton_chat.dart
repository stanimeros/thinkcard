import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonChat extends StatelessWidget {

  const SkeletonChat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(16, 0, 0, 0),
                  spreadRadius: 12,
                  blurRadius: 24,
                )
              ]
            ),
          ).animate(
            onComplete: (controller) {
              controller.repeat();
            },
          ).slideX(
            duration: const Duration(milliseconds: 2500),
            curve: Curves.linear,
            begin: -1.5,
            end: 1.5,
          ),
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                shape: BoxShape.circle
              ),
            ),
            title: Container(
              height: 13,
              decoration: BoxDecoration(
                color: const Color.fromARGB(16, 0, 0, 0),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            subtitle: Container(
              height: 13,
              decoration: BoxDecoration(
                color: const Color.fromARGB(16, 0, 0, 0),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        ],
      ),
    );
  }
}