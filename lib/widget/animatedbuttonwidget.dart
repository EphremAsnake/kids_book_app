// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:resize/resize.dart';
import 'package:storyapp/utils/Constants/colors.dart';

class AnimatedButtonWidget extends StatelessWidget {
  final Duration buttonDelayDuration;
  final Duration buttonPlayDuration;
  final String text;
  final IconData? icon;
  final bool? isRow;
  const AnimatedButtonWidget({
    Key? key,
    required this.buttonDelayDuration,
    required this.buttonPlayDuration,
    required this.text,
    this.icon,
    this.isRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          child: Container(
                  width: isRow == null
                      ? MediaQuery.of(context).size.width * .3
                      : MediaQuery.of(context).size.width * .145,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: AnimatedTextWidget(
                    buttonPlayDuration: buttonPlayDuration,
                    buttonDelayDuration: buttonDelayDuration,
                    text: text,
                    icon: icon,
                  ))
              .animate()
              .slideY(
                  begin: 1,
                  end: 0,
                  delay: buttonDelayDuration,
                  duration: buttonPlayDuration,
                  curve: Curves.easeInOutCubic),
        )
      ],
    );
  }
}

class AnimatedTextWidget extends StatelessWidget {
  final Duration buttonPlayDuration;
  final Duration buttonDelayDuration;
  final IconData? icon;
  final String text;
  const AnimatedTextWidget({
    Key? key,
    required this.buttonPlayDuration,
    required this.buttonDelayDuration,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: AppColors.iconColor,
            ),
          const SizedBox(
            width: 5,
          ),
          Text(text,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp)),
        ],
      ),
    ).animate().scaleXY(
        begin: 0,
        end: 1,
        delay: buttonDelayDuration + 300.ms,
        duration: buttonPlayDuration,
        curve: Curves.easeInOutCubic);
  }
}
