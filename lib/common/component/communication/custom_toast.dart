import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(String title, String message, ToastificationType type) {
  toastification.show(
    title: Text(title),
    description: Text(message),
    type: type,
    autoCloseDuration: const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 200),
    showProgressBar: true,
    alignment: Alignment.bottomRight,
  );
}
