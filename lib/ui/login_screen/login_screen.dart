import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/auth_session_manager.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:eism/ui/main_navigation_screen.dart';
import 'package:eism/ui/login_screen/widgets/auth_background.dart';
import 'package:eism/ui/login_screen/widgets/auth_logo.dart';
import 'package:eism/ui/login_screen/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eism/core/services/notification_service.dart';

import '../../core/data/api/api_client.dart';
import '../../core/data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthRepository _authRepository = AuthRepository(ApiClient());

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    final savedPassword = prefs.getString('saved_password');
    
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        String deviceId = '';
        String deviceType = '';

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
          deviceType = 'Android';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
          deviceType = 'iOS';
        }

        final response = await _authRepository.login(
          username: _usernameController.text,
          password: _passwordController.text,
          deviceID: deviceId,
          deviceType: deviceType,
          fcmToken: await NotificationService().getSavedToken(),
        );

        if (response.token != null) {
          AuthSessionManager.resetAuthFailureGuard();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response.token!);
          await prefs.setString('device_id', deviceId);
          await prefs.setString('device_type', deviceType);
          
          // Save credentials for easier login later if token expires
          await prefs.setString('saved_username', _usernameController.text);
          await prefs.setString('saved_password', _passwordController.text);
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, MainNavigationScreen.routeName);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.invalidCredentials.tr())),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                const AuthLogo(),
                SizedBox(height: 40.h),
                GlassContainer(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.loginTitle.tr(),
                          style: theme.textTheme.headlineLarge,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppStrings.loginSubtitle.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        AuthTextField(
                          controller: _usernameController,
                          hintText: AppStrings.username.tr(),
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterUsername.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: AppStrings.password.tr(),
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterPassword.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: GlassButton(
                            onPressed: _isLoading ? () {} : _handleLogin,
                            color: AppStyle.primaryBlue,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    AppStrings.login.tr(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  AppStrings.loginInfo.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
