import 'dart:async';
import 'package:eism/ui/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isHandlingAuthFailure = false;

  /// Handles HTTP 417 authentication session failure centrally.
  static Future<void> handle417AuthFailure() async {
    if (_isHandlingAuthFailure) return;
    _isHandlingAuthFailure = true;

    try {
      // 1. Clear authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      // Preserve non-authentication settings (device_id, device_type, saved_username, saved_password, app language, etc.)

      // 2. Perform navigation to LoginScreen immediately and clear the stack
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );

        // 3. Schedule SnackBar on LoginScreen's context immediately after the frame renders
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your session has expired. Please log in again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[AuthSessionManager] Error handling 417 auth failure: $e');
    }
  }

  /// Resets the authentication failure guard upon successful login.
  static void resetAuthFailureGuard() {
    _isHandlingAuthFailure = false;
  }
}
