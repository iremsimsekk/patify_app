import 'package:flutter/material.dart';

import '../models/appointment_slot.dart';
import '../services/app_preferences.dart';
import '../services/appointment_service.dart';
import '../theme/patify_theme.dart';
import '../widgets/patify_user_bottom_nav.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({
    super.key,
    required this.institutionId,
    required this.clinicName,
  });

  final int institutionId;
  final String clinicName;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  List<AppointmentSlot> _slots = const [];
  AppointmentSlot? _selectedSlot;
  bool _loading = true;
  bool _booking = false;
  String? _error;
  String? _authRole;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _authRole = await AppPreferences.loadAuthRole();
    _authToken = await AppPreferences.loadAuthToken();
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedSlot = null;
    });

    try {
      final slots = await AppointmentService.fetchAvailableSlots(
        institutionId: widget.institutionId,
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() => _slots = slots);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyLoadError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      initialDate: _selectedDate,
    );
    if (picked == null) return;
    setState(() => _selectedDate = DateUtils.dateOnly(picked));
    await _loadSlots();
  }

  Future<void> _book() async {
    if (_selectedSlot == null) {
      _showMessage('Lütfen önce bir randevu saati seç.', true);
      return;
    }
    if (_authToken == null || _authToken!.trim().isEmpty) {
      _showMessage('Randevu almak için giriş yapmalısınız.', true);
      return;
    }
    if (_authRole != 'USER') {
      _showMessage(
        'Randevu alma işlemi sadece normal kullanıcı hesapları için açık.',
        true,
      );
      return;
    }

    setState(() => _booking = true);
    try {
      await AppointmentService.bookSlot(_selectedSlot!.id);
      await _loadSlots();
      if (!mounted) return;
      _showMessage('Randevunuz oluşturuldu.', false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyBookingError(error), true);
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBook = _authRole == 'USER' && (_authToken?.isNotEmpty == true);

    return Scaffold(
      appBar: AppBar(title: const Text('Randevu Al')),
      bottomNavigationBar: const PatifyUserBottomNav(
        current: PatifyUserNavItem.appointments,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSlots,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            PatifyTheme.space20,
            PatifyTheme.space16,
            PatifyTheme.space20,
            PatifyTheme.space28,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFBEAE4),
                    Color(0xFFF8F4EE),
                  ],
                ),
                borderRadius: BorderRadius.circular(PatifyTheme.radius24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clinicName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: PatifyTheme.space8),
                  Text(
                    'Tarih seç, müsait slotları incele ve randevunu güvenle oluştur.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PatifyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: PatifyTheme.space16),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_formatDate(_selectedDate)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PatifyTheme.space16),
            if (!canBook)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space16),
                  child: Text(
                    _authToken == null || _authToken!.isEmpty
                        ? 'Randevu almak için giriş yapmalısınız.'
                        : 'Bu oturumla slotları görüntüleyebilirsin; randevu alma sadece normal kullanıcı hesabında açık.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uygun slotlar', style: theme.textTheme.titleMedium),
                    const SizedBox(height: PatifyTheme.space12),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(PatifyTheme.space20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Text(_error!, style: theme.textTheme.bodyMedium)
                    else if (_slots.isEmpty)
                      Text(
                        'Seçilen tarih için müsait randevu slotu bulunamadı.',
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      Column(
                        children: _slots.map((slot) {
                          final selected = _selectedSlot?.id == slot.id;
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: PatifyTheme.space12),
                            child: _SlotCard(
                              slot: slot,
                              selected: selected,
                              onTap: slot.isAvailable
                                  ? () => setState(() => _selectedSlot = slot)
                                  : null,
                            ),
                          );
                        }).toList(growable: false),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PatifyTheme.space12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _booking ? null : _book,
                icon: _booking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_booking ? 'İşleniyor...' : 'Randevuyu Onayla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? PatifyTheme.danger : null,
      ),
    );
  }

  String _friendlyLoadError(Object error) {
    return 'Slotlar alınamadı. Lütfen daha sonra tekrar dene.';
  }

  String _friendlyBookingError(Object error) {
    final message = error.toString();
    if (message.contains('APPOINTMENT_SLOT_NOT_AVAILABLE')) {
      return 'Bu slot az önce doldu veya artık uygun değil.';
    }
    if (message.contains('USER_ROLE_REQUIRED')) {
      return 'Randevu alma işlemi sadece normal kullanıcı hesapları için açık.';
    }
    if (message.contains('AUTH_TOKEN_MISSING')) {
      return 'Randevu almak için giriş yapmalısınız.';
    }
    return 'Randevu oluşturulamadı. Lütfen tekrar dene.';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final AppointmentSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        child: Ink(
          padding: const EdgeInsets.all(PatifyTheme.space16),
          decoration: BoxDecoration(
            color: selected
                ? PatifyTheme.primarySoft
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(PatifyTheme.radius20),
            border: Border.all(
              color: selected ? PatifyTheme.primary : PatifyTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PatifyTheme.secondarySoft,
                  borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: PatifyTheme.secondary,
                ),
              ),
              const SizedBox(width: PatifyTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_clock(slot.startTime)} - ${_clock(slot.endTime)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: PatifyTheme.space4),
                    Text(
                      slot.note?.isNotEmpty == true
                          ? slot.note!
                          : 'Durum: ${slot.status}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: PatifyTheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _clock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
