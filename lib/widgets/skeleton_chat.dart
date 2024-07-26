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
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surfaceContainer,
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
                color: Theme.of(context).splashColor.withOpacity(0.25),
                shape: BoxShape.circle
              ),
            ),
            title: Row(
              children: [
                Container(
                  height: 13,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).splashColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
            subtitle: Container(
              height: 13,
              decoration: BoxDecoration(
                color: Theme.of(context).splashColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        ],
      ),
    );
  }
}