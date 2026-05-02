import 'package:flutter/material.dart';

import '../models/appointment_slot.dart';
import '../services/app_preferences.dart';
import '../services/appointment_service.dart';
import '../theme/patify_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _loading = true;
  String? _error;
  String? _role;
  String? _token;
  List<AppointmentSlot> _appointments = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _role = await AppPreferences.loadAuthRole();
    _token = await AppPreferences.loadAuthToken();

    if (_token == null || _token!.isEmpty || _role != 'USER') {
      setState(() {
        _loading = false;
        _appointments = const [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final appointments = await AppointmentService.fetchMyAppointments();
      if (!mounted) return;
      setState(() => _appointments = appointments);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(AppointmentSlot slot) async {
    try {
      await AppointmentService.cancelMyBooking(slot.id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Randevu iptal edildi. Slot yeniden açıldı.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(error)),
          backgroundColor: PatifyTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Randevularım')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PatifyTheme.space20,
            PatifyTheme.space12,
            PatifyTheme.space20,
            PatifyTheme.space28,
          ),
          children: [
            Text('Yaklaşan randevular', style: theme.textTheme.headlineSmall),
            const SizedBox(height: PatifyTheme.space8),
            Text(
              'Aldığın veteriner randevularını tek yerden takip edebilir ve gerektiğinde iptal edebilirsin.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: PatifyTheme.space20),
            if (_token == null || _token!.isEmpty)
              const _MessageCard(
                title: 'Giriş gerekli',
                message: 'Randevularını görmek için giriş yapmalısın.',
              )
            else if (_role != 'USER')
              const _MessageCard(
                title: 'Bu hesap türü desteklenmiyor',
                message:
                    'Randevularım ekranı sadece normal kullanıcı hesaplarında kullanılabilir.',
              )
            else if (_loading)
              const Padding(
                padding: EdgeInsets.all(PatifyTheme.space24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _MessageCard(
                title: 'Randevular alınamadı',
                message: _error!,
              )
            else if (_appointments.isEmpty)
              const _MessageCard(
                title: 'Henüz randevu yok',
                message: 'Aldığın randevular burada listelenecek.',
              )
            else
              ..._appointments.map((slot) => Padding(
                    padding: const EdgeInsets.only(bottom: PatifyTheme.space12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(PatifyTheme.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    slot.institutionName,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: PatifyTheme.space12,
                                    vertical: PatifyTheme.space8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PatifyTheme.primarySoft,
                                    borderRadius: BorderRadius.circular(
                                      PatifyTheme.radius16,
                                    ),
                                  ),
                                  child: Text(
                                    slot.status,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: PatifyTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: PatifyTheme.space12),
                            Text(
                              '${_formatDate(slot.startTime)} • ${_formatClock(slot.startTime)} - ${_formatClock(slot.endTime)}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            if (slot.note?.isNotEmpty == true) ...[
                              const SizedBox(height: PatifyTheme.space8),
                              Text(
                                slot.note!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: PatifyTheme.space12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _cancel(slot),
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Randevuyu iptal et'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('APPOINTMENT_SLOT_BOOKING_ACCESS_DENIED')) {
      return 'Sadece kendi randevunu iptal edebilirsin.';
    }
    if (message.contains('APPOINTMENT_SLOT_NOT_BOOKED')) {
      return 'Bu randevu artık aktif görünmüyor.';
    }
    if (message.contains('USER_ROLE_REQUIRED')) {
      return 'Bu işlem sadece normal kullanıcı hesapları için açık.';
    }
    return 'İşlem tamamlanamadı. Lütfen tekrar dene.';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PatifyTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: PatifyTheme.space8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
