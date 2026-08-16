import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/profile_screen/widgets/language_selection_section.dart';
import 'package:eism/ui/profile_screen/widgets/profile_card.dart';
import 'package:eism/ui/profile_screen/widgets/profile_dropdown.dart';
import 'package:eism/ui/profile_screen/widgets/profile_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_style.dart';
import '../../core/data/api/api_client.dart';
import '../../core/data/models/job_domain_model.dart';
import '../../core/data/models/parent_status_model.dart';
import '../../core/data/repositories/parent_repository.dart';
import '../../core/managers/strings_manager.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/ProfileScreen';
  final ParentRepository? parentRepository;
  const ProfileScreen({super.key, this.parentRepository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (keeping existing controllers and state)
  final _formKey = GlobalKey<FormState>();
  late final ParentRepository _parentRepository;
  bool _isLoading = true;
  bool _isArabic = false;

  // Father's Controllers
  final _fatherNameController = TextEditingController(); 
  final _fatherTutorController = TextEditingController();
  final _fatherAddressController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherHomeTelController = TextEditingController();
  final _fatherCellularController = TextEditingController();
  final _fatherProfessionController = TextEditingController();
  final _fatherCompanyController = TextEditingController();
  final _fatherWorkplaceController = TextEditingController();
  final _fatherSchoolController = TextEditingController();
  final _fatherDiplomaController = TextEditingController();
  final _fatherOtherLangController = TextEditingController();

  // Mother's Controllers
  final _motherNameController = TextEditingController(); 
  final _motherTutorController = TextEditingController();
  final _motherAddressController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherHomeTelController = TextEditingController();
  final _motherCellularController = TextEditingController();
  final _motherProfessionController = TextEditingController();
  final _motherCompanyController = TextEditingController();
  final _motherWorkplaceController = TextEditingController();
  final _motherSchoolController = TextEditingController();
  final _motherDiplomaController = TextEditingController();
  final _motherOtherLangController = TextEditingController();

  // Emergency Controllers
  final _emergencyEmailController = TextEditingController();
  final _emergencyCellularController = TextEditingController();
  final _contact1NameController = TextEditingController();
  final _contact1RelationController = TextEditingController();
  final _contact1HomeTelController = TextEditingController();
  final _contact1MobileController = TextEditingController();
  final _contact2NameController = TextEditingController();
  final _contact2RelationController = TextEditingController();
  final _contact2HomeTelController = TextEditingController();
  final _contact2MobileController = TextEditingController();

  String? _fatherAreaOfWork;
  String? _motherAreaOfWork;
  String? _familySituation;

  List<String> _jobDomains = [];
  List<JobDomainModel> _jobDomainModels = [];
  List<String> _parentStatuses = [];
  List<ParentStatusModel> _parentStatusModels = [];

  String _localizeStatus(String? statusName) {
    if (statusName == null) return '';
    final key = statusName.toLowerCase().replaceAll(' ', '_');
    final localized = key.tr();
    return localized == key ? statusName : localized;
  }

  final List<String> _situationsKeys = [
    AppStrings.married,
    AppStrings.separated,
    AppStrings.divorced,
    AppStrings.deceasedFather,
    AppStrings.deceasedMother
  ];

  Map<String, bool> _fatherLanguages = {};
  Map<String, bool> _motherLanguages = {};
  final List<String> _defaultLanguages = ['Arabic', 'English', 'French'];

  @override
  void initState() {
    super.initState();
    _parentRepository = widget.parentRepository ?? ParentRepository(ApiClient());
    _loadProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isArabic = context.locale.languageCode == 'ar';
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final domains = await _parentRepository.getJobDomains(token);
      final List<String> domainList = domains
          .map((d) => _isArabic ? (d.jobdomain ?? '') : (d.jobdomainEn ?? ''))
          .where((s) => s.isNotEmpty)
          .toList();

      final statuses = await _parentRepository.getParentStatuses(token);
      final List<String> statusList = statuses
          .map((s) => _localizeStatus(s.parentStatus))
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> finalStatusList = statusList.isNotEmpty
          ? statusList
          : _situationsKeys.map((k) => k.tr()).toList();
      
      final langs = await _parentRepository.getParentLanguages(token);
      final List<String> langList = langs
          .map((l) => l.parentLang?.trim())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      final List<String> finalLangList = langList.isNotEmpty ? langList : _defaultLanguages;

      final data = await _parentRepository.getParentProfile(token);
      
      if (mounted) {
        setState(() {
          _jobDomainModels = domains;
          _jobDomains = domainList;
          _parentStatusModels = statuses;
          _parentStatuses = finalStatusList;

          _fatherLanguages = {for (var lang in finalLangList) lang: false};
          _motherLanguages = {for (var lang in finalLangList) lang: false};

          if (data != null) {
            _fatherNameController.text = data.fatherFullname ?? '';
            _fatherTutorController.text = data.fatherTuteur ?? '';
            _fatherAddressController.text = data.fatherAddress ?? '';
            _fatherEmailController.text = data.fatherEmail ?? '';
            _fatherHomeTelController.text = data.fatherHometel?.toString() ?? '';
            _fatherCellularController.text = data.fatherMobile?.toString() ?? '';
            _fatherProfessionController.text = data.fatherProfession ?? '';
            _fatherCompanyController.text = data.fatherCompany ?? '';
            _fatherWorkplaceController.text = data.fatherWorkplace ?? '';
            _fatherSchoolController.text = data.fatherSchool ?? '';
            _fatherDiplomaController.text = data.fatherDiplome ?? '';
            _fatherOtherLangController.text = data.fatherAutreslang ?? '';
            
            final fatherDomainModel = domains.firstWhere(
              (d) => d.serno?.toString() == data.fatherDomain?.toString() ||
                     d.jobdomain == data.fatherDomain?.toString() ||
                     d.jobdomainEn == data.fatherDomain?.toString(),
              orElse: () => JobDomainModel(),
            );
            _fatherAreaOfWork = fatherDomainModel.serno != null
                ? (_isArabic ? fatherDomainModel.jobdomain : fatherDomainModel.jobdomainEn)
                : null;

            final List<String> loadedLangs = [
              if (data.father1lang != null && data.father1lang!.trim().isNotEmpty) data.father1lang!.trim(),
              if (data.father2lang != null && data.father2lang!.trim().isNotEmpty) data.father2lang!.trim(),
              if (data.father3lang != null && data.father3lang!.trim().isNotEmpty) data.father3lang!.trim(),
              if (data.mother1lang != null && data.mother1lang!.trim().isNotEmpty) data.mother1lang!.trim(),
              if (data.mother2lang != null && data.mother2lang!.trim().isNotEmpty) data.mother2lang!.trim(),
              if (data.mother3lang != null && data.mother3lang!.trim().isNotEmpty) data.mother3lang!.trim(),
            ];
            for (var lang in loadedLangs) {
              _fatherLanguages[lang] = false;
              _motherLanguages[lang] = false;
            }

            for (var lang in _fatherLanguages.keys) {
              _fatherLanguages[lang] = 
                  data.father1lang?.trim() == lang || 
                  data.father2lang?.trim() == lang || 
                  data.father3lang?.trim() == lang;
            }

            _motherNameController.text = data.motherFullname ?? '';
            _motherTutorController.text = data.motherTuteur ?? '';
            _motherAddressController.text = data.motherAddress ?? '';
            _motherEmailController.text = data.motherEmail ?? '';
            _motherHomeTelController.text = data.motherHometel?.toString() ?? '';
            _motherCellularController.text = data.motherMobile?.toString() ?? '';
            _motherProfessionController.text = data.motherProfession ?? '';
            _motherCompanyController.text = data.motherCompany ?? '';
            _motherWorkplaceController.text = data.motherWorkplace ?? '';
            _motherSchoolController.text = data.motherSchool ?? '';
            _motherDiplomaController.text = data.motherDiplome ?? '';
            _motherOtherLangController.text = data.motherAutreslang ?? '';

            final motherDomainModel = domains.firstWhere(
              (d) => d.serno?.toString() == data.motherDomain?.toString() ||
                     d.jobdomain == data.motherDomain?.toString() ||
                     d.jobdomainEn == data.motherDomain?.toString(),
              orElse: () => JobDomainModel(),
            );
            _motherAreaOfWork = motherDomainModel.serno != null
                ? (_isArabic ? motherDomainModel.jobdomain : motherDomainModel.jobdomainEn)
                : null;

            for (var lang in _motherLanguages.keys) {
              _motherLanguages[lang] = 
                  data.mother1lang?.trim() == lang || 
                  data.mother2lang?.trim() == lang || 
                  data.mother3lang?.trim() == lang;
            }

            final statusModel = statuses.firstWhere(
              (s) => s.serNo?.toString() == data.familySituation?.toString() ||
                     s.serNo?.toString() == data.parentStatus?.toString() ||
                     s.serNo?.toString() == data.parentstatus?.toString() ||
                     s.parentStatus?.toLowerCase() == data.familySituation?.toString().toLowerCase() ||
                     s.parentStatus?.toLowerCase() == data.parentStatus?.toString().toLowerCase() ||
                     s.parentStatus?.toLowerCase() == data.parentstatus?.toString().toLowerCase(),
              orElse: () => ParentStatusModel(),
            );
            _familySituation = statusModel.serNo != null
                ? _localizeStatus(statusModel.parentStatus)
                : (data.familySituation != null
                    ? _localizeStatus(data.familySituation.toString())
                    : (data.parentStatus != null
                        ? _localizeStatus(data.parentStatus.toString())
                        : (data.parentstatus != null
                            ? _localizeStatus(data.parentstatus.toString())
                            : null)));
            if (_familySituation != null && !_parentStatuses.contains(_familySituation)) {
              _parentStatuses.add(_familySituation!);
            }

            _contact1NameController.text = data.urgentName1 ?? '';
            _contact1RelationController.text = data.urgentRelation1 ?? '';
            _contact1HomeTelController.text = data.urgentTel1?.toString() ?? '';
            _contact1MobileController.text = data.urgentMobile1?.toString() ?? '';
            
            _contact2NameController.text = data.urgentName2 ?? '';
            _contact2RelationController.text = data.urgentRelation2 ?? '';
            _contact2HomeTelController.text = data.urgentTel2?.toString() ?? '';
            _contact2MobileController.text = data.urgentMobile2?.toString() ?? '';

            _emergencyEmailController.text = data.fatherEmail ?? ''; 
            _emergencyCellularController.text = data.fatherMobile?.toString() ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final selectedFatherDomain = _jobDomainModels.firstWhere(
        (d) => (_isArabic ? d.jobdomain : d.jobdomainEn) == _fatherAreaOfWork,
        orElse: () => JobDomainModel(),
      );
      final selectedMotherDomain = _jobDomainModels.firstWhere(
        (d) => (_isArabic ? d.jobdomain : d.jobdomainEn) == _motherAreaOfWork,
        orElse: () => JobDomainModel(),
      );

      final selectedStatusModel = _parentStatusModels.firstWhere(
        (s) => _localizeStatus(s.parentStatus) == _familySituation,
        orElse: () => ParentStatusModel(),
      );

      final cleanFamilySituation = (_familySituation == null || _familySituation == 'null') ? '0' : _familySituation!;
      final fatherLangs = _fatherLanguages.entries.where((e) => e.value).map((e) => e.key).toList();
      final motherLangs = _motherLanguages.entries.where((e) => e.value).map((e) => e.key).toList();

      final generalSuccess = await _parentRepository.updateGeneralInfo(
        token: token,
        fatherTuteur: _fatherTutorController.text,
        fatherAddress: _fatherAddressController.text,
        motherTuteur: _motherTutorController.text,
        motherAddress: _motherAddressController.text,
        parentStatus: selectedStatusModel.serNo?.toString() ?? cleanFamilySituation,
      );

      final contactSuccess = await _parentRepository.updateContactInfo(
        token: token,
        fatherEmail: _fatherEmailController.text,
        fatherHomeTel: _fatherHomeTelController.text,
        fatherMobile: _fatherCellularController.text,
        motherEmail: _motherEmailController.text,
        motherHomeTel: _motherHomeTelController.text,
        motherMobile: _motherCellularController.text,
      );

      final workSuccess = await _parentRepository.updateWorkInfo(
        token: token,
        fatherProfession: _fatherProfessionController.text,
        fatherCompany: _fatherCompanyController.text,
        fatherWorkplace: _fatherWorkplaceController.text,
        fatherDomain: selectedFatherDomain.serno ?? 0,
        motherProfession: _motherProfessionController.text,
        motherCompany: _motherCompanyController.text,
        motherWorkplace: _motherWorkplaceController.text,
        motherDomain: selectedMotherDomain.serno ?? 0,
      );

      final educationSuccess = await _parentRepository.updateEducationInfo(
        token: token,
        fatherSchool: _fatherSchoolController.text,
        fatherDiplome: _fatherDiplomaController.text,
        father1lang: fatherLangs.isNotEmpty ? fatherLangs[0] : '',
        father2lang: fatherLangs.length > 1 ? fatherLangs[1] : '',
        father3lang: fatherLangs.length > 2 ? fatherLangs[2] : '',
        fatherAutreslang: _fatherOtherLangController.text,
        motherSchool: _motherSchoolController.text,
        motherDiplome: _motherDiplomaController.text,
        mother1lang: motherLangs.isNotEmpty ? motherLangs[0] : '',
        mother2lang: motherLangs.length > 1 ? motherLangs[1] : '',
        mother3lang: motherLangs.length > 2 ? motherLangs[2] : '',
        motherAutreslang: _motherOtherLangController.text,
      );

      final urgentSuccess = await _parentRepository.updateUrgentInfo(
        token: token,
        urgentName1: _contact1NameController.text,
        urgentParentrelation1: _contact1RelationController.text,
        urgentTel1: _contact1HomeTelController.text,
        urgentMobile1: _contact1MobileController.text,
        urgentName2: _contact2NameController.text,
        urgentParentrelation2: _contact2RelationController.text,
        urgentTel2: _contact2HomeTelController.text,
        urgentMobile2: _contact2MobileController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        List<String> failedSections = [];
        if (!generalSuccess) failedSections.add("${AppStrings.father.tr()}/${AppStrings.mother.tr()}");
        if (!contactSuccess) failedSections.add("${AppStrings.email.tr()}/${AppStrings.cellular.tr()}");
        if (!workSuccess) failedSections.add(AppStrings.areaOfWork.tr());
        if (!educationSuccess) failedSections.add(AppStrings.schoolReceivedEducation.tr());
        if (!urgentSuccess) failedSections.add(AppStrings.emergencyInfo.tr());

        if (failedSections.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.profileSaved.tr())));
        } else {
          String message = 'Failed to save: ${failedSections.join(', ')}';
          if (failedSections.length == 1 && !urgentSuccess) {
            message = 'Profile saved, but Emergency Info failed due to a server error.';
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _fatherTutorController.dispose();
    _fatherAddressController.dispose();
    _fatherEmailController.dispose();
    _fatherHomeTelController.dispose();
    _fatherCellularController.dispose();
    _fatherProfessionController.dispose();
    _fatherCompanyController.dispose();
    _fatherWorkplaceController.dispose();
    _fatherSchoolController.dispose();
    _fatherDiplomaController.dispose();
    _fatherOtherLangController.dispose();
    _motherNameController.dispose();
    _motherTutorController.dispose();
    _motherAddressController.dispose();
    _motherEmailController.dispose();
    _motherHomeTelController.dispose();
    _motherCellularController.dispose();
    _motherProfessionController.dispose();
    _motherCompanyController.dispose();
    _motherWorkplaceController.dispose();
    _motherSchoolController.dispose();
    _motherDiplomaController.dispose();
    _motherOtherLangController.dispose();
    _emergencyEmailController.dispose();
    _emergencyCellularController.dispose();
    _contact1NameController.dispose();
    _contact1RelationController.dispose();
    _contact1HomeTelController.dispose();
    _contact1MobileController.dispose();
    _contact2NameController.dispose();
    _contact2RelationController.dispose();
    _contact2HomeTelController.dispose();
    _contact2MobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: GlassScaffold(
        drawer: const AppDrawer(),
        appBar: GlassAppBar(
          title: Text(AppStrings.familyProfile.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveProfileData,
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelColor: AppStyle.primaryBlue,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
              indicatorColor: AppStyle.primaryBlue,
              indicatorWeight: 3,
              tabs: [
                Tab(text: AppStrings.father.tr()),
                Tab(text: AppStrings.mother.tr()),
                Tab(text: AppStrings.familySituation.tr()),
                Tab(text: AppStrings.emergencyInfo.tr()),
              ],
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: TabBarView(
                      children: [
                        _buildTabContent(_buildFatherSection()),
                        _buildTabContent(_buildMotherSection()),
                        _buildTabContent(_buildFamilySituationSection()),
                        _buildTabContent(_buildEmergencySection()),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget content) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      child: content,
    );
  }

  Widget _buildFatherSection() {
    return ProfileCard(
      children: [
        ProfileTextField(label: AppStrings.fatherFirstNameLastName.tr(), controller: _fatherNameController, enabled: false),
        ProfileTextField(label: AppStrings.tutorFirstNameLastName.tr(), controller: _fatherTutorController),
        ProfileTextField(label: AppStrings.privateAddress.tr(), controller: _fatherAddressController),
        ProfileTextField(label: AppStrings.email.tr(), controller: _fatherEmailController, keyboardType: TextInputType.emailAddress),
        ProfileTextField(label: AppStrings.homeTel.tr(), controller: _fatherHomeTelController, keyboardType: TextInputType.phone),
        ProfileTextField(label: AppStrings.cellular.tr(), controller: _fatherCellularController, keyboardType: TextInputType.phone),
        ProfileDropdown(
          label: AppStrings.areaOfWork.tr(), 
          value: _jobDomains.contains(_fatherAreaOfWork) ? _fatherAreaOfWork : null, 
          items: _jobDomains, 
          onChanged: (val) => setState(() => _fatherAreaOfWork = val)
        ),
        ProfileTextField(label: AppStrings.profession.tr(), controller: _fatherProfessionController, hint: AppStrings.noProfessionHint.tr()),
        ProfileTextField(label: AppStrings.companyName.tr(), controller: _fatherCompanyController),
        ProfileTextField(label: AppStrings.workplace.tr(), controller: _fatherWorkplaceController),
        ProfileTextField(label: AppStrings.schoolReceivedEducation.tr(), controller: _fatherSchoolController),
        ProfileTextField(label: AppStrings.diploma.tr(), controller: _fatherDiplomaController),
        LanguageSelectionSection(label: AppStrings.masteredLanguages.tr(), languages: _fatherLanguages, otherController: _fatherOtherLangController),
      ],
    );
  }

  Widget _buildMotherSection() {
    return ProfileCard(
      children: [
        ProfileTextField(label: AppStrings.motherFirstNameLastName.tr(), controller: _motherNameController, enabled: false),
        ProfileTextField(label: AppStrings.tutorFirstNameLastName.tr(), controller: _motherTutorController),
        ProfileTextField(label: AppStrings.privateAddress.tr(), controller: _motherAddressController),
        ProfileTextField(label: AppStrings.email.tr(), controller: _motherEmailController, keyboardType: TextInputType.emailAddress),
        ProfileTextField(label: AppStrings.homeTel.tr(), controller: _motherHomeTelController, keyboardType: TextInputType.phone),
        ProfileTextField(label: AppStrings.cellular.tr(), controller: _motherCellularController, keyboardType: TextInputType.phone),
        ProfileDropdown(
          label: AppStrings.areaOfWork.tr(), 
          value: _jobDomains.contains(_motherAreaOfWork) ? _motherAreaOfWork : null, 
          items: _jobDomains, 
          onChanged: (val) => setState(() => _motherAreaOfWork = val)
        ),
        ProfileTextField(label: AppStrings.profession.tr(), controller: _motherProfessionController, hint: AppStrings.noProfessionHint.tr()),
        ProfileTextField(label: AppStrings.companyName.tr(), controller: _motherCompanyController),
        ProfileTextField(label: AppStrings.workplace.tr(), controller: _motherWorkplaceController),
        ProfileTextField(label: AppStrings.schoolReceivedEducation.tr(), controller: _motherSchoolController),
        ProfileTextField(label: AppStrings.diploma.tr(), controller: _motherDiplomaController),
        LanguageSelectionSection(label: AppStrings.masteredLanguages.tr(), languages: _motherLanguages, otherController: _motherOtherLangController),
      ],
    );
  }

  Widget _buildFamilySituationSection() {
    return ProfileCard(
      children: [
        ProfileDropdown(
          label: AppStrings.familySituation.tr(), 
          value: _parentStatuses.contains(_familySituation) ? _familySituation : null, 
          items: _parentStatuses, 
          onChanged: (val) => setState(() => _familySituation = val)
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return ProfileCard(
      children: [
        ProfileTextField(label: AppStrings.email.tr(), controller: _emergencyEmailController, keyboardType: TextInputType.emailAddress),
        ProfileTextField(label: AppStrings.cellular.tr(), controller: _emergencyCellularController, keyboardType: TextInputType.phone),
        const Divider(),
        Text(AppStrings.emergencyContact1.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: AppStyle.primaryBlue)),
        ProfileTextField(label: AppStrings.personName.tr(), controller: _contact1NameController),
        ProfileTextField(label: AppStrings.relation.tr(), controller: _contact1RelationController),
        ProfileTextField(label: AppStrings.homeTel.tr(), controller: _contact1HomeTelController, keyboardType: TextInputType.phone),
        ProfileTextField(label: AppStrings.mobileNumber.tr(), controller: _contact1MobileController, keyboardType: TextInputType.phone),
        const Divider(),
        Text(AppStrings.emergencyContact2.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: AppStyle.primaryBlue)),
        ProfileTextField(label: AppStrings.personName.tr(), controller: _contact2NameController),
        ProfileTextField(label: AppStrings.relation.tr(), controller: _contact2RelationController),
        ProfileTextField(label: AppStrings.homeTel.tr(), controller: _contact2HomeTelController, keyboardType: TextInputType.phone),
        ProfileTextField(label: AppStrings.mobileNumber.tr(), controller: _contact2MobileController, keyboardType: TextInputType.phone),
      ],
    );
  }
}
