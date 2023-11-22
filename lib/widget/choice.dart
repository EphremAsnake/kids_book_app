import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoiceDialogBox extends StatefulWidget {
  final String? title, descriptions, text, sectext;
  final String? img;
  final Color? titleColor;
  final Function? functionCall,secfunctionCall;

  const ChoiceDialogBox(
      {Key? key,
      this.title,
      this.descriptions,
      this.text,
      this.img,
      this.titleColor,
      this.functionCall,
      this.sectext, this.secfunctionCall})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChoiceDialogBoxState createState() => _ChoiceDialogBoxState();
}

class _ChoiceDialogBoxState extends State<ChoiceDialogBox> {
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
          //height: MediaQuery.sizeOf(context).width * 0.4,
          width: MediaQuery.sizeOf(context).width * 0.4,
          padding: const EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: const EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.title == null
                  ? const SizedBox()
                  : Text(
                      widget.title!,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: widget.titleColor),
                    ),
              widget.title == null
                  ? const SizedBox()
                  : const SizedBox(
                      height: 15,
                    ),
              Text(
                widget.descriptions!,
                style: const TextStyle(fontSize: 14, color: Color(0xff3E3E3E)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () => widget.functionCall!(),
                        child: Container(
                          height: 47,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                              color: widget.titleColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              widget.text!,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),

                  //!second button
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () => widget.secfunctionCall!(),
                        child: Container(
                          height: 47,
                          padding: const EdgeInsets.all(12.0),
                          //width: MediaQuery.of(context).size.width * .1,
                          decoration: BoxDecoration(
                              color: widget.titleColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              '  ${widget.sectext!}   ',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
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
      ],
    );
  }
}

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}
