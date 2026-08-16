import 'package:eism/core/data/api/api_client.dart';
import 'package:eism/core/data/repositories/student_repository.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/core/providers/student_provider.dart';
import 'package:eism/ui/Student/bulletin_screen/widgets/bulletin_item_card.dart';
import 'package:eism/ui/Student/bulletin_screen/widgets/bulletin_model.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class BulletinScreen extends StatefulWidget {
  static const routeName = '/BulletinScreen';
  const BulletinScreen({super.key});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  final StudentRepository _studentRepository = StudentRepository(ApiClient());
  List<Bulletin> _bulletins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBulletins();
  }

  Future<void> _fetchBulletins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final stdID = studentProvider.selectedStudent?.id?.toString() ?? '';

      if (stdID.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _studentRepository.getStudentLinks(token: token, stdID: stdID);
      final List<dynamic> data = response['Data'] ?? [];

      if (mounted) {
        setState(() {
          _bulletins = data
              .where((item) => item['sublink_desc_e'] == 'Bulletin')
              .map((item) => Bulletin(
                    title: item['sublink_desc_e'] ?? 'Bulletin',
                    date: '', // Date not provided in the new API
                    url: item['sublink_urlname_e'] ?? '',
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bulletins: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppStrings.schoolBulletins.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchBulletins();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bulletins.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.announcement_outlined, size: 80.sp, color: Colors.grey.withAlpha(100)),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.noBulletins.tr(),
                        style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: _bulletins.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final bulletin = _bulletins[index];
                    return BulletinItemCard(
                      bulletin: bulletin,
                      onTap: () => _openBulletinWebView(context, bulletin),
                    );
                  },
                ),
    );
  }

  void _openBulletinWebView(BuildContext context, Bulletin bulletin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BulletinWebView(bulletin: bulletin),
      ),
    );
  }
}

class BulletinWebView extends StatefulWidget {
  final Bulletin bulletin;
  const BulletinWebView({super.key, required this.bulletin});

  @override
  State<BulletinWebView> createState() => _BulletinWebViewState();
}

class _BulletinWebViewState extends State<BulletinWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.bulletin.url));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.bulletin.title,
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
