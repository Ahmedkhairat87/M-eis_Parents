import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/cas_screen/widgets/cas_participant_card.dart';
import 'package:eism/ui/cas_screen/widgets/cas_progress_card.dart';
import 'package:eism/ui/cas_screen/widgets/cas_project_details.dart';
import 'package:eism/ui/cas_screen/widgets/cas_project_model.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';

class CreativityActivityService extends StatefulWidget {
  static const routeName = '/CreativityActivityService';
  const CreativityActivityService({super.key});

  @override
  State<CreativityActivityService> createState() => _CreativityActivityServiceState();
}

class _CreativityActivityServiceState extends State<CreativityActivityService> {
  // ... (keeping existing logic)
  final List<CASProject> _offeredProjects = const [
    CASProject(
      title: 'School Garden Renovation',
      brief: 'Join us in beautifying our school grounds! We need parents to help plant new flowers, paint benches, and install a sustainable irrigation system. No gardening experience required!',
      points: 10,
    ),
    CASProject(
      title: 'Charity Food Drive',
      brief: 'Help us collect and distribute non-perishable food items for local families in need. Volunteers will assist in sorting donations and managing the distribution logistics at the school center.',
      points: 5,
    ),
    CASProject(
      title: 'Tech Literacy Workshop',
      brief: 'Share your computer skills with members of our community who need help with basic digital tasks. This project involves a series of weekend workshops in the school computer lab.',
      points: 15,
    ),
  ];

  CASProject? _selectedProject;
  bool _fatherParticipating = false;
  bool _motherParticipating = false;
  
  final int _totalPointsAchieved = 25; 
  final int _targetPoints = 40;

  void _onParticipate() {
    if (_selectedProject == null) return;
    if (!_fatherParticipating && !_motherParticipating) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.selectParticipant.tr())),
      );
      return;
    }

    int potentialPoints = (_fatherParticipating && _motherParticipating) 
        ? _selectedProject!.points * 2 
        : _selectedProject!.points;

    showAppDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.confirmParticipation.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppStyle.primaryDarkBlue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '${_selectedProject!.title}\n'
              '${AppStrings.reports.tr()}: $potentialPoints\n\n'
              '${AppStrings.casVerificationInfo.tr()}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.cancel.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppStyle.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                  AppButton(
                    width: 140.w,
                    height: 48.h,
                    color: AppStyle.primaryBlue,
                    borderRadius: 16.r,
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.participationSent.tr())),
                      );
                    },
                    child: Text(
                      AppStrings.confirm.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      drawer: const AppDrawer(),
      appBar: GlassAppBar(
        title: Text(AppStrings.casCommunityService.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CASProgressCard(totalPointsAchieved: _totalPointsAchieved, targetPoints: _targetPoints),
            SizedBox(height: 30.h),
            _buildSectionTitle(AppStrings.availableProjects.tr()),
            SizedBox(height: 12.h),
            _buildProjectDropdown(),
            
            if (_selectedProject != null) ...[
              SizedBox(height: 20.h),
              CASProjectDetails(project: _selectedProject!),
              SizedBox(height: 24.h),
              _buildParticipantSelection(),
              SizedBox(height: 32.h),
              _buildActionButtons(),
            ],
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppStyle.primaryDarkBlue,
      ),
    );
  }

  Widget _buildProjectDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CASProject>(
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          hint: Text(AppStrings.selectCommunityProject.tr()),
          value: _selectedProject,
          onChanged: (CASProject? newValue) {
            setState(() {
              _selectedProject = newValue;
              _fatherParticipating = false;
              _motherParticipating = false;
            });
          },
          items: _offeredProjects.map((CASProject project) {
            return DropdownMenuItem<CASProject>(
              value: project,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      project.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppStyle.primaryBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${project.points} pts',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppStyle.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildParticipantSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.whoWillParticipate.tr()),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: CASParticipantCard(
                label: AppStrings.father.tr(),
                icon: Icons.man_rounded,
                isSelected: _fatherParticipating,
                onChanged: (val) => setState(() => _fatherParticipating = val!),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: CASParticipantCard(
                label: AppStrings.mother.tr(),
                icon: Icons.woman_rounded,
                isSelected: _motherParticipating,
                onChanged: (val) => setState(() => _motherParticipating = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 32.h),
      child: GlassButton(
        width: double.infinity,
        height: 56.h,
        onPressed: _onParticipate,
        color: AppStyle.primaryBlue,
        borderRadius: 20.r,
        child: Text(
          AppStrings.joinProject.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
