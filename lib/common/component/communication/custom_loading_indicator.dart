import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.spacing,
  });

  final Color? color;
  final double? size;
  final double? spacing;

  @override
  State<CustomLoadingIndicator> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Start animations with delays
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing ?? 4.0),
          child: FadeTransition(
            opacity: _animations[index],
            child: Container(
              width: widget.size ?? 8.0,
              height: widget.size ?? 8.0,
              decoration: BoxDecoration(
                color: widget.color ?? context.colors.surface,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
