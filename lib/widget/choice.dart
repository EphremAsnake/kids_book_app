import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoiceDialogBox extends StatefulWidget {
  final String? title, descriptions, text;
  final Color? titleColor;
  final bool? closeicon;
  final Function? functionCall, secfunctionCall;

  const ChoiceDialogBox(
      {Key? key,
      this.title,
      this.descriptions,
      this.text,
      this.titleColor,
      this.functionCall,
      this.secfunctionCall,
      this.closeicon})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChoiceDialogBoxState createState() => _ChoiceDialogBoxState();
}

class _ChoiceDialogBoxState extends State<ChoiceDialogBox> {
  late Color buttonColor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonColor = widget.titleColor!;
  }

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
              top: 30,
              right: Constants.padding,
              bottom: 30),
          margin: const EdgeInsets.only(top: 10),
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
                  : Center(
                      child: Text(
                        widget.title!,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: widget.titleColor),
                      ),
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
              Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        buttonColor = widget.titleColor!.withOpacity(0.5);
                      });

                      Future.delayed(const Duration(milliseconds: 100), () {
                        setState(() {
                          buttonColor = widget.titleColor!;
                        });
                      });
                      widget.functionCall!();
                    },
                    child: Container(
                      height: 47,
                      width: MediaQuery.of(context).size.width * .5,
                      decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(
                          widget.text!,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                  ),
            ],
          ),
        ),
        // Positioned(
        //   left: Constants.padding,
        //   right: Constants.padding,
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     radius: Constants.avatarRadius,
        //     child: ClipRRect(
        //         borderRadius: const BorderRadius.all(
        //             Radius.circular(Constants.avatarRadius)),
        //         child: SvgPicture.asset('${widget.img}')),
        //   ),
        // ),
        if (widget.closeicon == null)
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
