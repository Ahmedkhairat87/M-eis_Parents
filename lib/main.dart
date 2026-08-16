import 'package:eism/core/providers/parent_provider.dart';
import 'package:eism/core/providers/student_provider.dart';
// ... rest of imports
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/ui/Student/bulletin_screen/bulletin_screen.dart';
import 'package:eism/ui/Student/homework_screen/homework_screen.dart';
import 'package:eism/ui/Student/landing_screen/landing_screen.dart';
import 'package:eism/ui/Student/ministryReports_screen/ministryReports_screen.dart';
import 'package:eism/ui/Student/newsletter_screen/newsletter_screen.dart';
import 'package:eism/ui/Student/reports_screen/reports_screen.dart';
import 'package:eism/ui/Student/studentBook_screen/studentBook_screen.dart';
import 'package:eism/ui/Student/weeklyPlan_screen/weeklyPlan_screen.dart';
import 'package:eism/ui/cas_screen/cas_screen.dart';
import 'package:eism/ui/home_screen/home_screen.dart';
import 'package:eism/ui/main_navigation_screen.dart';
import 'package:eism/ui/login_screen/login_screen.dart';
import 'package:eism/ui/login_screen/profileSelection_screen.dart';
import 'package:eism/ui/massages_screen/massages_screen.dart';
import 'package:eism/ui/profile_screen/profile_screen.dart';
import 'package:eism/ui/setting_screen/privacy_security_screen.dart';
import 'package:eism/ui/setting_screen/setting.dart';
import 'package:eism/ui/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/app_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => ParentProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final lightTheme = AppStyle.lightMode.copyWith(
          extensions: [themeProvider.glassTheme],
        );
        final darkTheme = AppStyle.darkMode.copyWith(
          extensions: [themeProvider.glassTheme],
        );

        return MaterialApp(
          title: "The Egyptian International School In Al-Mi'rag",
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            ProfileSelectionScreen.routeName: (_) => const ProfileSelectionScreen(),
            HomeScreen.routeName: (_) => const MainNavigationScreen(),
            MainNavigationScreen.routeName: (_) => const MainNavigationScreen(),
            LandingScreen.routeName: (_) => const LandingScreen(),
            CreativityActivityService.routeName: (_) => const CreativityActivityService(),
            MassagesScreen.routeName: (_) => const MassagesScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            BulletinScreen.routeName: (_) => const BulletinScreen(),
            WeeklyPlanScreen.routeName: (_) => const WeeklyPlanScreen(),
            StudentbookScreen.routeName: (_) => const StudentbookScreen(),
            ReportsScreen.routeName: (_) => const ReportsScreen(),
            MinistryreportsScreen.routeName: (_) => const MinistryreportsScreen(),
            NewsletterScreen.routeName: (_) => const NewsletterScreen(),
            HomeworkScreen.routeName: (_) => const HomeworkScreen(),
            SettingScreen.routeName: (_) => const SettingScreen(),
            PrivacySecurityScreen.routeName: (_) => const PrivacySecurityScreen(),
          },
        );
      },
    );
  }
}
