import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  double _downloadProgress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final directory = await getTemporaryDirectory();
      final filename = '${widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final filePath = p.join(directory.path, filename);

      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
        return;
      }

      await Dio().download(
        widget.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load PDF: $e';
      });
    }
  }

  Future<void> _saveToDownloads() async {
    if (_localPath == null || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // Permission handling for Android
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.request().isGranted || 
            await Permission.storage.request().isGranted) {
          // Continue
        } else {
          throw Exception('Storage permission denied');
        }
      }

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadsDir.exists()) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final filename = '${widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final savePath = p.join(downloadsDir.path, filename);

      final sourceFile = File(_localPath!);
      await sourceFile.copy(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to: $savePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              icon: _isDownloading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded),
              onPressed: _saveToDownloads,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Loading PDF... ${(_downloadProgress * 100).toInt()}%',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _downloadPdf,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PDFView(
      filePath: _localPath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      backgroundColor: Colors.transparent,
      onError: (error) {
        setState(() => _error = error.toString());
      },
      onPageError: (page, error) {
        setState(() => _error = error.toString());
      },
    );
  }
}
