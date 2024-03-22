import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'getpermission.dart';

class Permission {
  static void getPermission({
    required BuildContext context,
    required Color backgroundColor,
    void Function()? onSuccess,
    void Function()? onFail,
    void Function()? onClose,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6, // Adjust as needed
            height: MediaQuery.of(context).size.height * 0.7, // Adjust as needed
            child: GetParentPermission(
              onClose: onClose,
              bgColor: backgroundColor,
            ),
          ),
        );
      },
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
    ).then((value) {
      if (value != null&& value is bool) {
        if (value) {
          if (onSuccess != null) onSuccess();
        } else {
          if (onFail != null) onFail();
        }
      } else {
        if (onFail != null) onFail();
      }
    });
  }
}
