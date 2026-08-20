import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/landing_screen/widgets/landing_menu_card.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/Student/bulletin_screen/bulletin_screen.dart';
import 'package:eism/ui/Student/homework_screen/homework_screen.dart';
import 'package:eism/ui/Student/ministryReports_screen/ministryReports_screen.dart';
import 'package:eism/ui/Student/reports_screen/reports_screen.dart';
import 'package:eism/ui/Student/studentBook_screen/studentBook_screen.dart';
import 'package:eism/ui/Student/weeklyPlan_screen/weeklyPlan_screen.dart';
import 'package:eism/ui/main_navigation_screen.dart';
import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  static const routeName = '/LandingScreen';
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.selectedStudent;

    return GlassScaffold(
      appBar: GlassAppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), 
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: AppStrings.notifications.tr(),
            onPressed: () {
              // Notification logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_work_rounded, color: Colors.greenAccent),
            tooltip: AppStrings.parentHome.tr(),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.routeName, (route) => false);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(contextRole: DrawerContext.student),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.childFollowUp.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${AppStrings.reviewingProgress.tr()} ${student?.name ?? ""}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Student Info Card
          SliverToBoxAdapter(
            child: GlassContainer(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(20.w),
              color: AppStyle.primaryBlue,
              opacity: isDark ? 0.3 : 0.6,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 40.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.name ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.studentAcademicPortal.tr(),
                          style: TextStyle(
                            color: Colors.white.withAlpha(210),
                            fontSize: 12.sp,
                          ),
                        ),
                        if (student?.grade != null)
                          Text(
                            student!.gradeName,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          AppStrings.academicYear.tr(),
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 30.h)),

          // Menu Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 15.w,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                LandingMenuCard(
                  title: AppStrings.weeklyPlan.tr(),
                  icon: Icons.calendar_month_rounded,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, WeeklyPlanScreen.routeName),
                ),
                LandingMenuCard(
                  title: AppStrings.homework.tr(),
                  icon: Icons.edit_note_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, HomeworkScreen.routeName),
                ),
                LandingMenuCard(
                  title: AppStrings.studentBook.tr(),
                  icon: Icons.menu_book_rounded,
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, StudentbookScreen.routeName),
                ),
                LandingMenuCard(
                  title: AppStrings.bulletin.tr(),
                  icon: Icons.notifications_active_rounded,
                  color: Colors.redAccent,
                  onTap: () => Navigator.pushNamed(context, BulletinScreen.routeName),
                ),
                LandingMenuCard(
                  title: AppStrings.reports.tr(),
                  icon: Icons.assessment_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, ReportsScreen.routeName),
                ),
                LandingMenuCard(
                  title: AppStrings.ministryReports.tr(),
                  icon: Icons.account_balance_rounded,
                  color: Colors.brown,
                  onTap: () => Navigator.pushNamed(context, MinistryreportsScreen.routeName),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }
}
