import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resize/resize.dart';

class AboutDialogBox extends StatefulWidget {
  final String? descriptions, text;
  final Color? titleColor;
  final String? img;
  final Function? secfunctionCall;

  const AboutDialogBox(
      {Key? key,
      this.descriptions,
      this.text,
      this.titleColor,
      this.secfunctionCall,
      this.img})
      : super(key: key);

  @override

  // ignore: library_private_types_in_public_api
  _AboutDialogBoxState createState() => _AboutDialogBoxState();
}

class _AboutDialogBoxState extends State<AboutDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.sizeOf(context).width * 0.5,
          height: MediaQuery.sizeOf(context).height * 0.8,
          padding: const EdgeInsets.only(
              left: Constants.padding,
              top: 20,
              right: Constants.padding,
              bottom: 30),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/splashlogo.png"),
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                Text(
                  widget.descriptions!,
                  style: TextStyle(
                    fontFamily: 'StoryText',
                    fontSize: 8.sp,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 22,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(
                    Radius.circular(Constants.avatarRadius)),
                child: SvgPicture.asset('${widget.img}')),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => widget.secfunctionCall!(),
            child: CircleAvatar(
                backgroundColor: widget.titleColor,
                radius: Constants.avatarRadius / 3,
                child: const Icon(Icons.close, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}
