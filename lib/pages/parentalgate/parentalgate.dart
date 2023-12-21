// Importing necessary packages
import 'package:flutter/material.dart';

import 'getpermission.dart';

// Importing the PermissionScreen class from the same library

// A class providing a method to get parental permission
class Permission {
  // Static method to show a permission screen and handle success or failure
  static void getPermission({
    required BuildContext context,
    required backgroundColor,
    void Function()? onSuccess,
    void Function()? onFail,
  }) {
    // Push the permission screen onto the navigator stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GetParentPermission(
          bgColor: backgroundColor,
        ),
      ),
    ).then((value) {
      // Check the result from the permission screen
      if (value != null) {
        if (value) {
          // If permission granted, call the onSuccess callback
          if (onSuccess != null) onSuccess();
        } else {
          // If permission denied, call the onFail callback
          if (onFail != null) onFail();
        }
      } else {
        // If the result is null, call the onFail callback
        if (onFail != null) onFail();
      }
    });
  }
}
