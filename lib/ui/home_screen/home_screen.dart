import 'package:eism/core/app_style.dart';
import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_container.dart';
import 'package:eism/ui/widgets/glass/glass_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:eism/ui/login_screen/login_screen.dart';
import 'package:eism/ui/login_screen/profileSelection_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreenContent';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WebViewController _webViewController;

  final List<Map<String, String>> _videos = [
    {'title': 'School Activity 1', 'url': 'https://www.dailymotion.com/video/x4463oy', 'type': 'dailymotion'},
    {'title': 'School Activity 2', 'url': 'https://www.dailymotion.com/video/x4463vk', 'type': 'dailymotion'},
    {'title': 'Educational Video 1', 'url': 'https://www.youtube.com/watch?v=mIshK4VuwRo', 'type': 'youtube', 'id': 'mIshK4VuwRo'},
    {'title': 'Educational Video 2', 'url': 'https://www.youtube.com/watch?v=MouJGbKGS_s', 'type': 'youtube', 'id': 'MouJGbKGS_s'},
  ];

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://www.m-eis.com/parent/parentInside/default.aspx'));
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        content: GlassContainer(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.logout.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppStyle.primaryDarkBlue,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.logoutConfirm.tr(),
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
                    style: TextButton.styleFrom(
                      minimumSize: Size(100.w, 48.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
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
                  GlassButton(
                    width: 140.w,
                    height: 48.h,
                    color: AppStyle.errorRed,
                    borderRadius: 16.r,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('auth_token');
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
                      }
                    },
                    child: Text(
                      AppStrings.logout.tr(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(AppStrings.home.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: AppStrings.notifications.tr(),
            onPressed: () {
              // Notification logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: AppStrings.switchProfile.tr(),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, ProfileSelectionScreen.routeName, (route) => false);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(contextRole: DrawerContext.parent),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, AppStrings.schoolPortal.tr()),
              SizedBox(height: 12.h),
              GlassContainer(
                height: 350.h,
                borderRadius: BorderRadius.circular(16.r),
                padding: EdgeInsets.zero,
                child: WebViewWidget(
                  controller: _webViewController,
                  gestureRecognizers: {
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),
                  },
                ),
              ),
              SizedBox(height: 30.h),
              _buildSectionTitle(context, AppStrings.videoHighlights.tr()),
              SizedBox(height: 12.h),
              SizedBox(
                height: 160.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    return _buildVideoCard(context, _videos[index]);
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, String> video) {
    bool isYoutube = video['type'] == 'youtube';
    String thumbnailUrl = isYoutube 
      ? 'https://img.youtube.com/vi/${video['id']}/mqdefault.jpg'
      : 'https://www.dailymotion.com/thumbnail/video/${video['url']!.split('/').last}';

    return GlassContainer(
      width: 240.w,
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          Image.network(
            thumbnailUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withAlpha(76),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if (isYoutube) {
                  _showYoutubePlayer(video['id']!);
                } else {
                  _launchURL(video['url']!);
                }
              },
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
            ),
          ),
          Positioned(
            bottom: 8.h,
            left: 8.w,
            right: 8.w,
            child: Text(
              video['title']!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showYoutubePlayer(String videoId) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: AspectRatio(
          aspectRatio: 16 / 9,
          child: GlassContainer(
            padding: EdgeInsets.zero,
            child: YoutubePlayer(
              controller: controller,
            ),
          ),
        ),
      ),
    ).then((_) => controller.close());
  }
}
