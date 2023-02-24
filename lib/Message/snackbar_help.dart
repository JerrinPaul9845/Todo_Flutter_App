import 'package:flutter/material.dart';

void showFailMessage(
  BuildContext context, {
  required String message,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red[900],
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
