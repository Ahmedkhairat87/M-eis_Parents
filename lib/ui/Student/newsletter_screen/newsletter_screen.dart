import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/Student/newsletter_screen/widgets/newsletter_model.dart';
import 'package:eism/ui/Student/newsletter_screen/widgets/newsletter_tile.dart';
import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/api/api_client.dart';
import '../../../core/data/repositories/parent_repository.dart';

class NewsletterScreen extends StatefulWidget {
  static const routeName = '/NewsletterScreen';
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  final ParentRepository _parentRepository = ParentRepository(ApiClient());
  List<Newsletter> _newsletters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewsletters();
  }

  Future<void> _fetchNewsletters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final data = await _parentRepository.getNewsletters(token);
      
      if (mounted) {
        setState(() {
          _newsletters = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading newsletters: $e')),
        );
      }
    }
  }

  Future<void> _openNewsletter(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.couldNotOpenPdf.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      drawer: const AppDrawer(),
      appBar: GlassAppBar(
        title: Text(AppStrings.schoolNewsletters.tr()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchNewsletters();
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _newsletters.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchNewsletters,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                itemCount: _newsletters.length,
                itemBuilder: (context, index) {
                  return NewsletterTile(
                    newsletter: _newsletters[index], 
                    onTap: () => _openNewsletter(_newsletters[index].pdfUrl)
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_outlined, size: 80.sp, color: Colors.grey.withAlpha(100)),
          SizedBox(height: 16.h),
          Text(
            AppStrings.noNewsletters.tr(),
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

