import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/lost_report_service.dart';
import '../theme/patify_theme.dart';
import 'lost_report_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.currentUser,
  });

  final AppUser currentUser;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<LostReportNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LostReportNotification>> _load() {
    return LostReportService.notifications(email: widget.currentUser.email);
  }

  Future<void> _openDetail(LostReportNotification notification) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LostReportDetailScreen(
          reportId: notification.lostReportId,
          currentUser: widget.currentUser,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<LostReportNotification>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data ?? const [];
            if (notifications.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(PatifyTheme.space20),
                children: const [
                  _EmptyNotifications(),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(PatifyTheme.space16),
                    leading: const CircleAvatar(
                      child: Icon(Icons.notifications_active_rounded),
                    ),
                    title: Text(notification.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: PatifyTheme.space4),
                      child: Text(notification.message),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () => _openDetail(notification),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_none_rounded),
          SizedBox(width: PatifyTheme.space12),
          Expanded(child: Text('Henüz bildirimin yok.')),
        ],
      ),
    );
  }
}
