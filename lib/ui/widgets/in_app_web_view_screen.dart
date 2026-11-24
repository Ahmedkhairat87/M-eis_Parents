import 'package:eism/core/app_style.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebViewScreen extends StatefulWidget {
  static const routeName = '/InAppWebViewScreen';

  final String url;
  final String? title;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String? _errorMessage;
  String _pageTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title ?? _getDisplayHost(widget.url);
    _initWebViewController();
  }

  String _getDisplayHost(String urlStr) {
    try {
      final uri = Uri.parse(urlStr);
      return uri.host.isNotEmpty ? uri.host : urlStr;
    } catch (_) {
      return urlStr;
    }
  }

  Future<void> _updateNavigationState() async {
    final canBack = await _controller.canGoBack();
    final canForward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canForward;
      });
    }
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              final title = await _controller.getTitle();
              final canBack = await _controller.canGoBack();
              final canForward = await _controller.canGoForward();
              setState(() {
                _isLoading = false;
                if (title != null && title.trim().isNotEmpty) {
                  _pageTitle = title;
                }
                _canGoBack = canBack;
                _canGoForward = canForward;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load webpage: ${error.description}';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          _pageTitle,
          style: TextStyle(fontSize: 15.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: _canGoBack ? (isDark ? Colors.white : AppStyle.primaryDarkBlue) : Colors.grey),
            onPressed: _canGoBack
                ? () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                      await _updateNavigationState();
                    }
                  }
                : null,
            tooltip: 'Back',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: _canGoForward ? (isDark ? Colors.white : AppStyle.primaryDarkBlue) : Colors.grey),
            onPressed: _canGoForward
                ? () async {
                    if (await _controller.canGoForward()) {
                      await _controller.goForward();
                      await _updateNavigationState();
                    }
                  }
                : null,
            tooltip: 'Forward',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
              });
              _controller.reload();
            },
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    SizedBox(height: 16.h),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: Colors.redAccent),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isLoading = true;
                        });
                        _controller.reload();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppStyle.primaryBlue),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_isLoading && _errorMessage == null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AppStyle.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }
}
