// lib/widgets/notification_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showBadge;
  final int? count;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.showBadge,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.8,
                  end: 1.2,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                ),
          ),
      ],
    );
  }
}
