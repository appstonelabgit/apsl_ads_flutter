import 'dart:async';

import 'package:flutter/material.dart';

Future showAutoHideLoaderDialog(BuildContext context, {int delay = 2}) {
  const alert = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text("Loading Ad ..."),
      ],
    ),
  );

  final navigator = Navigator.of(context);
  Future.delayed(Duration(seconds: delay), () {
    if (navigator.mounted) {
      navigator.pop();
    }
  });
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => alert,
  );
}

// Global variable to hold the completer instance
// Completer<void>? _dialogCompleter;

GlobalKey<State> _loaderKey = GlobalKey<State>();

void showLoaderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false, // Prevent back button closing dialog
        child: AlertDialog(
          key: _loaderKey,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Loading Ad ..."),
            ],
          ),
        ),
      );
    },
  );
}

void hideLoaderDialog() {
  if (_loaderKey.currentContext != null) {
    Navigator.of(_loaderKey.currentContext!, rootNavigator: true).pop();
    _loaderKey = GlobalKey<State>();
  }
}
