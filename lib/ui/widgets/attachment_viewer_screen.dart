import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:eism/core/app_style.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum FileCategory {
  pdf,
  video,
  image,
  docx,
  xlsx,
  csv,
  text,
  externalOffice,
  unknown,
}

class AttachmentViewerScreen extends StatefulWidget {
  static const routeName = '/AttachmentViewerScreen';

  final String title;
  final String url;
  final String? mimeType;

  const AttachmentViewerScreen({
    super.key,
    required this.title,
    required this.url,
    this.mimeType,
  });

  @override
  State<AttachmentViewerScreen> createState() => _AttachmentViewerScreenState();
}

class _AttachmentViewerScreenState extends State<AttachmentViewerScreen> {
  String? _localPath;
  int _fileSizeInBytes = 0;
  bool _isLoading = true;
  String? _errorMessage;
  double _downloadProgress = 0.0;
  bool _isSaving = false;

  late FileCategory _category;

  // Video Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // PDF State
  int _pdfPages = 0;
  int _pdfCurrentPage = 0;
  PDFViewController? _pdfViewController;

  // Word Document Text (.docx)
  String? _docxText;

  // Excel Data (.xlsx)
  excel_pkg.Excel? _excelData;

  // CSV / Text Data
  List<List<dynamic>>? _csvTable;
  String? _plainTextContent;

  @override
  void initState() {
    super.initState();
    _category = _detectFileCategory(widget.url, widget.title, widget.mimeType);
    _initializeAndLoad();
  }

  /// Helper to safely normalize and encode attachment URLs for network requests without double-encoding %20
  String _normalizeAttachmentUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    try {
      // Uri.encodeFull encodes spaces and unsafe characters while preserving valid URL structures and existing %20 encodings
      return Uri.encodeFull(trimmed);
    } catch (_) {
      return trimmed.replaceAll(' ', '%20');
    }
  }

  FileCategory _detectFileCategory(String url, String fileName, String? mime) {
    // Strip query parameters and fragments before checking extension
    final cleanUrl = url.split('?').first.split('#').first;
    final nameOrUrl = fileName.trim().isNotEmpty ? fileName : cleanUrl;
    final ext = p.extension(nameOrUrl).toLowerCase();

    // Check extension first for specific match
    if (ext == '.pdf') return FileCategory.pdf;
    if ([
      '.mp4',
      '.mov',
      '.m4v',
      '.webm',
      '.avi',
      '.mkv',
      '.3gp',
    ].contains(ext)) {
      return FileCategory.video;
    }
    if ([
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
      '.heic',
    ].contains(ext)) {
      return FileCategory.image;
    }
    if (ext == '.txt') return FileCategory.text;
    if (ext == '.csv') return FileCategory.csv;
    if (ext == '.docx') return FileCategory.docx;
    if (ext == '.xlsx') return FileCategory.xlsx;
    if (['.doc', '.xls', '.ppt', '.pptx'].contains(ext)) {
      return FileCategory.externalOffice;
    }

    // Fallback to MIME type if extension is absent or ambiguous
    if (mime != null && mime.isNotEmpty) {
      final m = mime.toLowerCase();
      if (m.contains('pdf')) return FileCategory.pdf;
      if (m.contains('video')) return FileCategory.video;
      if (m.contains('image')) return FileCategory.image;
      if (m.contains('text/plain')) return FileCategory.text;
      if (m.contains('csv')) return FileCategory.csv;
      if (m.contains('wordprocessingml')) return FileCategory.docx;
      if (m.contains('spreadsheetml')) return FileCategory.xlsx;
      if (m.contains('word') ||
          m.contains('excel') ||
          m.contains('presentation') ||
          m.contains('officedocument')) {
        return FileCategory.externalOffice;
      }
    }

    return FileCategory.unknown;
  }

  Future<void> _initializeAndLoad() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _downloadProgress = 0.0;
      });

      final path = await _downloadAuthenticatedFile();
      _localPath = path;

      final file = File(path);
      if (await file.exists()) {
        _fileSizeInBytes = await file.length();
      }

      await _setupCategoryViewer();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getFriendlyErrorMessage(e);
        });
      }
    }
  }

  String _getFriendlyErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return 'Session expired. Please sign in again to view this attachment.';
      }
      if (e.response?.statusCode == 404) {
        return 'Attachment not found on the server.';
      }
    }
    return 'Failed to load attachment. Please check your connection and try again.';
  }

  /// Centralized Authenticated File Downloader
  Future<String> _downloadAuthenticatedFile() async {
    // Safely percent-encode attachment path segments for network request
    final String normalizedUrl = _normalizeAttachmentUrl(widget.url);

    // Strip query parameters and URL fragments to produce clean URL path for extension extraction & caching
    final cleanUrl = normalizedUrl.split('?').first.split('#').first;

    String ext = p.extension(widget.title).toLowerCase();
    if (ext.isEmpty || ext.length > 5) {
      ext = p.extension(cleanUrl).toLowerCase();
    }

    final rawTitle = widget.title.isNotEmpty
        ? widget.title
        : p.basenameWithoutExtension(cleanUrl);
    String sanitizedTitle = rawTitle.replaceAll(RegExp(r'[^\w\s.-]'), '_');

    // Remove duplicated extension if sanitizedTitle already ends with ext
    if (ext.isNotEmpty &&
        sanitizedTitle.toLowerCase().endsWith(ext.toLowerCase())) {
      sanitizedTitle = sanitizedTitle.substring(
        0,
        sanitizedTitle.length - ext.length,
      );
    }

    // SHA-256 hash of cleanUrl (URL stripped of sensitive query strings/tokens and fragments) for deterministic, safe cache key
    final urlHash = sha256
        .convert(utf8.encode(cleanUrl))
        .toString()
        .substring(0, 16);
    final cacheFileName = '${sanitizedTitle}_$urlHash$ext';

    final directory = await getTemporaryDirectory();
    final filePath = p.join(directory.path, cacheFileName);

    final file = File(filePath);
    if (await file.exists() && await file.length() > 0) {
      return filePath;
    }

    // Retrieve authentication token securely from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = <String, dynamic>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      await Dio().download(
        normalizedUrl,
        filePath,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
    } on DioException catch (e) {
      debugPrint('========== ATTACHMENT DOWNLOAD ERROR ==========');
      debugPrint('Original URL: ${widget.url}');
      debugPrint('Normalized URL: $normalizedUrl');
      debugPrint('Dio Type: ${e.type}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('Error: ${e.error}');
      debugPrint('===============================================');
      rethrow;
    }

    return filePath;
  }

  Future<void> _setupCategoryViewer() async {
    if (_localPath == null) return;
    final file = File(_localPath!);

    if (_category == FileCategory.video) {
      try {
        _videoPlayerController = VideoPlayerController.file(file);
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Video Playback Error: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
      } catch (e) {
        _errorMessage = 'Could not load video player.';
      }
    } else if (_category == FileCategory.text) {
      try {
        _plainTextContent = await file.readAsString();
      } catch (_) {
        _plainTextContent = null;
      }
    } else if (_category == FileCategory.csv) {
      try {
        final content = await file.readAsString();
        _csvTable = const CsvToListConverter().convert(content);
      } catch (_) {
        _csvTable = null;
      }
    } else if (_category == FileCategory.docx) {
      try {
        final bytes = await file.readAsBytes();
        _docxText = docxToText(bytes);
      } catch (_) {
        _docxText = null;
      }
    } else if (_category == FileCategory.xlsx) {
      try {
        final bytes = await file.readAsBytes();
        _excelData = excel_pkg.Excel.decodeBytes(bytes);
      } catch (_) {
        _excelData = null;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToDownloads() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final String filePath = _localPath ?? await _downloadAuthenticatedFile();

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        try {
          downloadsDir = await getDownloadsDirectory();
        } catch (_) {}
        downloadsDir ??= (await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        ))?.firstOrNull;
        downloadsDir ??= await getExternalStorageDirectory();
        downloadsDir ??= await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final cleanUrl = widget.url.split('?').first.split('#').first;
      String ext = p.extension(filePath).toLowerCase();
      if (ext.isEmpty) ext = p.extension(cleanUrl).toLowerCase();

      final rawTitle = widget.title.isNotEmpty
          ? widget.title
          : p.basenameWithoutExtension(cleanUrl);
      String sanitizedTitle = rawTitle.replaceAll(RegExp(r'[^\w\s.-]'), '_');

      if (ext.isNotEmpty &&
          sanitizedTitle.toLowerCase().endsWith(ext.toLowerCase())) {
        sanitizedTitle = sanitizedTitle.substring(
          0,
          sanitizedTitle.length - ext.length,
        );
      }

      final saveFileName = '$sanitizedTitle$ext';
      final savePath = p.join(downloadsDir.path, saveFileName);

      await File(filePath).copy(savePath);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File saved to: $saveFileName')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openExternalFallback() async {
    if (_localPath == null) return;
    final result = await OpenFilex.open(_localPath!);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.title.isNotEmpty ? widget.title : 'Attachment Viewer',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              onPressed: _saveToDownloads,
              tooltip: 'Save File',
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
              _downloadProgress > 0
                  ? 'Downloading attachment... ${(_downloadProgress * 100).toInt()}%'
                  : 'Preparing attachment...',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.redAccent),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _initializeAndLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              if (_localPath != null) ...[
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  onPressed: _openExternalFallback,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Local File in System App'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    switch (_category) {
      case FileCategory.pdf:
        return _buildPdfViewer();
      case FileCategory.video:
        return _buildVideoViewer();
      case FileCategory.image:
        return _buildImageViewer();
      case FileCategory.text:
        return _buildTextViewer();
      case FileCategory.csv:
        return _buildCsvViewer();
      case FileCategory.docx:
        return _buildDocxViewer();
      case FileCategory.xlsx:
        return _buildXlsxViewer();
      case FileCategory.externalOffice:
      case FileCategory.unknown:
        return _buildExternalOfficeOrUnknownViewer();
    }
  }

  Widget _buildPdfViewer() {
    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: _localPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            backgroundColor: Colors.transparent,
            onRender: (pages) {
              setState(() => _pdfPages = pages ?? 0);
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() => _pdfCurrentPage = page ?? 0);
            },
            onError: (error) {
              setState(() => _errorMessage = error.toString());
            },
          ),
        ),
        if (_pdfPages > 0)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            color: Colors.black12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _pdfCurrentPage > 0
                      ? () => _pdfViewController?.setPage(_pdfCurrentPage - 1)
                      : null,
                ),
                Text(
                  'Page ${_pdfCurrentPage + 1} of $_pdfPages',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _pdfCurrentPage < _pdfPages - 1
                      ? () => _pdfViewController?.setPage(_pdfCurrentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVideoViewer() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildImageViewer() {
    if (_localPath == null) return const SizedBox.shrink();

    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.8,
        maxScale: 4.0,
        child: Image.file(
          File(_localPath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextViewer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: SelectableText(
        _plainTextContent ?? 'No text content available.',
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.5,
          fontFamily: 'monospace',
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCsvViewer() {
    if (_csvTable == null || _csvTable!.isEmpty) {
      return const Center(
        child: Text('CSV file is empty or could not be parsed.'),
      );
    }

    // Determine max columns to safely pad rows for DataTable
    int maxCols = 0;
    for (var row in _csvTable!) {
      if (row.length > maxCols) {
        maxCols = row.length;
      }
    }

    if (maxCols == 0) {
      return const Center(child: Text('CSV contains no data columns.'));
    }

    final headerRow = _csvTable!.first;
    final dataRows = _csvTable!.skip(1).toList();

    final List<DataColumn> columns = [];
    for (int i = 0; i < maxCols; i++) {
      final String colName = i < headerRow.length
          ? headerRow[i].toString().trim()
          : 'Col ${i + 1}';
      columns.add(
        DataColumn(
          label: Text(
            colName.isNotEmpty ? colName : 'Col ${i + 1}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
        ),
      );
    }

    final List<DataRow> rows = dataRows.map((row) {
      final List<DataCell> cells = [];
      for (int i = 0; i < maxCols; i++) {
        final String cellVal = i < row.length ? row[i].toString().trim() : '';
        cells.add(DataCell(Text(cellVal, style: TextStyle(fontSize: 12.sp))));
      }
      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: columns, rows: rows),
      ),
    );
  }

  Widget _buildDocxViewer() {
    if (_docxText == null || _docxText!.trim().isEmpty) {
      return _buildExternalOfficeOrUnknownViewer();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  color: AppStyle.primaryBlue,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Document Content Preview',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.primaryBlue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SelectableText(
              _docxText!.trim(),
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXlsxViewer() {
    if (_excelData == null || _excelData!.tables.isEmpty) {
      return _buildExternalOfficeOrUnknownViewer();
    }

    final sheetNames = _excelData!.tables.keys.toList();

    return DefaultTabController(
      length: sheetNames.length,
      child: Column(
        children: [
          if (sheetNames.length > 1)
            TabBar(
              isScrollable: true,
              tabs: sheetNames.map((name) => Tab(text: name)).toList(),
            ),
          Expanded(
            child: TabBarView(
              children: sheetNames.map((sheetName) {
                final table = _excelData!.tables[sheetName];
                if (table == null || table.rows.isEmpty) {
                  return const Center(child: Text('Sheet is empty'));
                }

                final rows = table.rows;
                int maxCols = 0;
                for (var r in rows) {
                  if (r.length > maxCols) {
                    maxCols = r.length;
                  }
                }

                if (maxCols == 0) {
                  return const Center(child: Text('Sheet contains no data'));
                }

                final headerRow = rows.first;
                final dataRows = rows.skip(1).toList();

                final List<DataColumn> columns = [];
                for (int i = 0; i < maxCols; i++) {
                  final String colName = i < headerRow.length
                      ? (headerRow[i]?.value?.toString() ?? 'Col ${i + 1}')
                      : 'Col ${i + 1}';
                  columns.add(
                    DataColumn(
                      label: Text(
                        colName.isNotEmpty ? colName : 'Col ${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  );
                }

                final List<DataRow> tableRows = dataRows.map((row) {
                  final List<DataCell> cells = [];
                  for (int i = 0; i < maxCols; i++) {
                    final String cellVal = i < row.length
                        ? (row[i]?.value?.toString() ?? '')
                        : '';
                    cells.add(
                      DataCell(
                        Text(cellVal, style: TextStyle(fontSize: 12.sp)),
                      ),
                    );
                  }
                  return DataRow(cells: cells);
                }).toList();

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: columns, rows: tableRows),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalOfficeOrUnknownViewer() {
    final String fileSizeText = _fileSizeInBytes > 0
        ? '${(_fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
        : '';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80.sp,
              color: AppStyle.primaryBlue,
            ),
            SizedBox(height: 16.h),
            Text(
              widget.title.isNotEmpty ? widget.title : 'File Attachment',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            if (fileSizeText.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                fileSizeText,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Downloaded & Verified Locally',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _saveToDownloads,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Save File to Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
            if (_localPath != null) ...[
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: _openExternalFallback,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Local File in System App'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
