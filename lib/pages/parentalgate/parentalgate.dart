import 'package:flutter/material.dart';

import 'getpermission.dart';


class Permission {
  
  static void getPermission({
    required BuildContext context,
    required backgroundColor,
    void Function()? onSuccess,
    void Function()? onFail,
    void Function()? onClose,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GetParentPermission(
          onClose: onClose,
          bgColor: backgroundColor,
        ),
      ),
    ).then((value) {
      if (value != null) {
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
