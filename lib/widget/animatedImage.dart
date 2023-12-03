import 'package:flutter/material.dart';
import 'package:resize/resize.dart';

class AnimatedImageWidget extends StatefulWidget {
  final Widget childWidget;
  final String imageurl;

  const AnimatedImageWidget(
      {super.key, required this.childWidget, required this.imageurl});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedImageWidgetState createState() => _AnimatedImageWidgetState();
}

class _AnimatedImageWidgetState extends State<AnimatedImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Trigger the animation when the widget is created
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedImageWidget oldimageurl) {
    super.didUpdateWidget(oldimageurl);

    if (widget.imageurl != oldimageurl.imageurl) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
            opacity: _fadeInAnimation.value, child: widget.childWidget);
      },
    );
  }
}
