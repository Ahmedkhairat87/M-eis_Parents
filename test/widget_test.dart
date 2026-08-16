import 'package:eism/core/data/api/api_client.dart';
import 'package:eism/core/data/models/job_domain_model.dart';
import 'package:eism/core/data/models/login_response.dart';
import 'package:eism/core/data/models/parent_lang_model.dart';
import 'package:eism/core/data/models/parent_status_model.dart';
import 'package:eism/core/data/repositories/parent_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eism/ui/profile_screen/profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:eism/core/providers/theme_provider.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FakeParentRepository extends ParentRepository {
  FakeParentRepository() : super(ApiClient());

  @override
  Future<List<JobDomainModel>> getJobDomains(String token) async {
    return [
      JobDomainModel(serno: 1, jobdomain: 'مجال 1', jobdomainEn: 'Domain 1'),
      JobDomainModel(serno: 2, jobdomain: 'مجال 2', jobdomainEn: 'Domain 2'),
    ];
  }

  @override
  Future<List<ParentStatusModel>> getParentStatuses(String token) async {
    return [
      ParentStatusModel(serNo: 1, parentStatus: 'Married'),
      ParentStatusModel(serNo: 2, parentStatus: 'Separated'),
    ];
  }

  @override
  Future<List<ParentLangModel>> getParentLanguages(String token) async {
    return [
      ParentLangModel(serno: 1, parentLang: 'Arabic'),
      ParentLangModel(serno: 2, parentLang: 'English'),
      ParentLangModel(serno: 3, parentLang: 'French'),
    ];
  }

  @override
  Future<FamilyData?> getParentProfile(String token) async {
    return FamilyData(
      fatherFullname: 'John Doe',
      fatherDomain: 1,
      motherFullname: 'Jane Doe',
      motherDomain: 2,
      familySituation: 1,
      father1lang: 'Arabic',
      mother1lang: 'English',
    );
  }
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('ProfileScreen initial load test with mock repository', (WidgetTester tester) async {
    final fakeRepo = FakeParentRepository();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => StudentProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: ProfileScreen(parentRepository: fakeRepo),
            ),
          ),
        ),
      ),
    );
    
    // Let the async tasks complete
    await tester.pumpAndSettle();

    // Verify loading indicator is gone and ProfileScreen form is visible
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Form), findsOneWidget);
    
    // Verify mapped data is present in fields (e.g. John Doe)
    expect(find.text('John Doe'), findsOneWidget);
  });
}
