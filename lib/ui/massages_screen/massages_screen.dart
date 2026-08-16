import 'package:eism/core/managers/strings_manager.dart';
import 'package:eism/ui/massages_screen/widgets/compose_message_sheet.dart';
import 'package:eism/ui/massages_screen/widgets/message_list.dart';
import 'package:eism/ui/massages_screen/widgets/message_model.dart';
import 'package:eism/ui/widgets/glass/glass_app_bar.dart';
import 'package:eism/ui/widgets/glass/glass_scaffold.dart';
import 'package:eism/ui/widgets/glass/glass_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eism/ui/widgets/app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eism/core/providers/theme_provider.dart';

import '../../core/data/api/api_client.dart';
import '../../core/data/repositories/message_repository.dart';

class MassagesScreen extends StatefulWidget {
  static const routeName = '/MassagesScreen';
  const MassagesScreen({super.key});

  @override
  State<MassagesScreen> createState() => _MassagesScreenState();
}

class _MassagesScreenState extends State<MassagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessageRepository _messageRepository = MessageRepository(ApiClient());
  
  List<Message> _inbox = [];
  List<Message> _sent = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final data = await _messageRepository.getMessages(token);

      final dynamic rawInbox = data['Data1'] ?? data['data'] ?? [];
      final dynamic rawSent = data['Data2'] ?? [];
      
      final List<dynamic> inboxList = rawInbox is List ? rawInbox : [];
      final List<dynamic> sentList = rawSent is List ? rawSent : [];
      
      if (mounted) {
        setState(() {
          _inbox = inboxList
              .whereType<Map<String, dynamic>>()
              .map((json) => Message.fromJson(json))
              .toList();
          _sent = sentList
              .whereType<Map<String, dynamic>>()
              .map((json) => Message.fromJson(json, isSent: true))
              .toList();
          _unreadCount = int.tryParse(data['UnReadedCount']?.toString() ?? '0') ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final data = await _messageRepository.loadMoreInbox(token, _inbox.length);
      final List<dynamic> moreInbox = data['Data1'] ?? [];
      
      if (mounted && moreInbox.isNotEmpty) {
        setState(() {
          _inbox.addAll(moreInbox.map((json) => Message.fromJson(json)).toList());
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadMoreSent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final data = await _messageRepository.loadMoreSent(token, _sent.length);
      final List<dynamic> moreSent = data['Data1'] ?? []; // Assuming Data1 for sent load more too as per pattern
      
      if (mounted && moreSent.isNotEmpty) {
        setState(() {
          _sent.addAll(moreSent.map((json) => Message.fromJson(json, isSent: true)).toList());
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openComposeDialog() async {
    final result = await showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      child: const ComposeMessageSheet(),
    );
    
    if (result == true) {
      _fetchMessages(); // Refresh if message sent
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassScaffold(
      drawer: const AppDrawer(),
      appBar: GlassAppBar(
        title: Text(AppStrings.coordinatorMessages.tr()),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Badge(
                  label: Text(_unreadCount.toString()),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 40.h),
        child: FloatingActionButton(
          onPressed: _openComposeDialog,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: isDark ? Colors.white : Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(icon: const Icon(Icons.inbox), text: AppStrings.inbox.tr()),
              Tab(icon: const Icon(Icons.send), text: AppStrings.sent.tr()),
            ],
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      onRefresh: _fetchMessages,
                      child: MessageList(
                        messages: _inbox, 
                        onLoadMore: _loadMoreInbox,
                        onMessageRead: () {
                          if (_unreadCount > 0) {
                            setState(() => _unreadCount--);
                          }
                        },
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: _fetchMessages,
                      child: MessageList(
                        messages: _sent, 
                        onLoadMore: _loadMoreSent,
                        onMessageRead: () {}, 
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

