import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is AuthException) {
      message = error.message;
    } else if (error is PostgrestException) {
      message = error.message;
    } else if (error is StorageException) {
      message = error.message;
    } else if (error.toString().contains('Network') || error.toString().contains('Socket')) {
      message = 'Please check your internet connection';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is AuthException) return error.message;
    if (error is PostgrestException) return error.message;
    if (error is StorageException) return error.message;
    return error.toString();
  }
}

extension AsyncErrorX on BuildContext {
  void handleAsyncError(AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      GlobalErrorHandler.handleError(this, snapshot.error);
    }
  }
}
