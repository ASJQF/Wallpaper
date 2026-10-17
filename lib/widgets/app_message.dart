import 'package:flutter/material.dart';

void showAppMessage(
  BuildContext context,
  String message, {
  double bottom = 24,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottom),
        content: Text(message),
      ),
    );
}
