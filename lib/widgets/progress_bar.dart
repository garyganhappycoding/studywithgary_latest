import 'package:flutter/material.dart';


class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color progressBarColor;
  final double height;
  final double borderRadius;


  const ProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.progressBarColor = Colors.deepPurple,
    this.height = 20.0,
    this.borderRadius = 10.0,
  });


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: progressBarColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

