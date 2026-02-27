import 'package:flutter/material.dart';

class BaseModal {
  
  static Future<bool> confirm(
    BuildContext context, {
    String title = 'Confirm',
    String message = 'Are you sure?',
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
    Color? confirmButtonColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: confirmButtonColor != null ? ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result == true;
  }

  static Future<void> alert(
    BuildContext context, {
    String title = 'Notice',
    required String message,
    String buttonText = 'OK',
    Color? buttonColor,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: buttonColor != null ? ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
