// import 'package:toast/toast.dart';
import 'package:flutter/material.dart';

// alertDialog(BuildContext context, String msg) {
//   ToastContext().init(context);
//   Toast.show(msg, duration: Toast.lengthLong, gravity: Toast.bottom);
// }

validateEmail(String email) {
  final emailReg = RegExp(
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  return emailReg.hasMatch(email);
}