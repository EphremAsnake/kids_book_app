import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String? title, descriptions, text, text2;
  final Color? titleColor;
  final bool? closeicon;
  final bool? fromexitdialog;
  final Function? functionCall, secfunctionCall;

  const CustomDialogBox(
      {Key? key,
      this.title,
      this.descriptions,
      this.text,
      this.titleColor,
      this.functionCall,
      this.secfunctionCall,
      this.closeicon,
      this.text2,
      this.fromexitdialog})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChoiceDialogBoxState createState() => _ChoiceDialogBoxState();
}

class _ChoiceDialogBoxState extends State<CustomDialogBox> {
  late Color buttonColor;
  late Color buttonColor2;
  @override
  void initState() {
    super.initState();
    buttonColor = widget.titleColor!;
    buttonColor2 = widget.titleColor!;
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
                            fontFamily: 'Customfont',
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
                style: const TextStyle(
                  fontFamily: 'Customfont',
                  fontSize: 17,
                  color: Color(0xff3E3E3E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.functionCall != null && widget.text != null)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            buttonColor = Colors.grey;
                          });

                          await Future.delayed(const Duration(milliseconds: 30),
                              () {
                            setState(() {
                              buttonColor = widget.titleColor!;
                            });
                          });
                          widget.functionCall!();
                        },
                        child: Container(
                          height: 47,
                          width: MediaQuery.of(context).size.width * .15,
                          decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Text(
                              widget.text!.toUpperCase(),
                              style: const TextStyle(
                                  fontFamily: 'Customfont',
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // const SizedBox(width: 10,),
                  if (widget.functionCall != null && widget.text != null)
                    const SizedBox(
                      width: 10,
                    ),

                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          buttonColor2 = Colors.grey;
                        });

                        await Future.delayed(const Duration(milliseconds: 30),
                            () {
                          setState(() {
                            buttonColor2 = widget.titleColor!;
                          });
                        });
                        widget.secfunctionCall!();
                      },
                      child: Container(
                        height: 47,
                        width: MediaQuery.of(context).size.width * .15,
                        decoration: BoxDecoration(
                            color: buttonColor2,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            widget.text2!.toUpperCase(),
                            style: const TextStyle(
                                fontFamily: 'Customfont',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.closeicon == null)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => widget.fromexitdialog == null
                  ? Navigator.pop(context)
                  : widget.secfunctionCall!(),
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
