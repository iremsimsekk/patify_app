import 'package:flutter/material.dart';

import '../models/appointment_slot.dart';
import '../services/app_preferences.dart';
import '../services/appointment_service.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../theme/patify_theme.dart';

class VeterinaryDetailScreen extends StatefulWidget {
  const VeterinaryDetailScreen({
    super.key,
    required this.apiKey,
    required this.placeId,
    required this.title,
  });

  final String apiKey;
  final String placeId;
  final String title;

  @override
  State<VeterinaryDetailScreen> createState() => _VeterinaryDetailScreenState();
}

class _VeterinaryDetailScreenState extends State<VeterinaryDetailScreen> {
  late final Future<PlaceDetails> _detailsFuture;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  bool _slotsLoading = true;
  bool _booking = false;
  String? _slotError;
  String? _authRole;
  String? _authToken;
  List<AppointmentSlot> _availableSlots = const [];
  AppointmentSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        InstitutionApiService.fetchInstitutionDetails(widget.placeId);
    _initialize();
  }

  Future<void> _initialize() async {
    _authRole = await AppPreferences.loadAuthRole();
    _authToken = await AppPreferences.loadAuthToken();
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    final institutionId = int.tryParse(widget.placeId);
    if (institutionId == null) {
      setState(() {
        _slotsLoading = false;
        _slotError = 'Bu klinik için randevu altyapısı henüz desteklenmiyor.';
      });
      return;
    }

    setState(() {
      _slotsLoading = true;
      _slotError = null;
      _selectedSlot = null;
    });

    try {
      final slots = await AppointmentService.fetchAvailableSlots(
        institutionId: institutionId,
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() => _availableSlots = slots);
    } catch (error) {
      if (!mounted) return;
      setState(() => _slotError = _friendlyLoadError(error));
    } finally {
      if (mounted) setState(() => _slotsLoading = false);
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

  Future<void> _bookSelectedSlot() async {
    if (_selectedSlot == null) {
      _showMessage('Lütfen önce bir saat seç.', true);
      return;
    }
    if (_authToken == null || _authToken!.trim().isEmpty) {
      _showMessage('Randevu almak için giriş yapman gerekiyor.', true);
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
      _showMessage('Randevun başarıyla oluşturuldu.', false);
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<PlaceDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          final details = snapshot.data;
          final loadingDetails =
              snapshot.connectionState != ConnectionState.done;

          return RefreshIndicator(
            onRefresh: _loadSlots,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PatifyTheme.space20,
                PatifyTheme.space16,
                PatifyTheme.space20,
                PatifyTheme.space28,
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(PatifyTheme.space16),
                    child: loadingDetails
                        ? const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Klinik bilgileri yükleniyor...',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 12),
                              LinearProgressIndicator(),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details?.name ?? widget.title,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: PatifyTheme.space12),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: details?.formattedAddress ??
                                    'Adres bilgisi yok',
                              ),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                text: details?.phone ?? 'Telefon bilgisi yok',
                              ),
                              _InfoRow(
                                icon: Icons.mail_outline_rounded,
                                text: details?.email ?? 'E-posta bilgisi yok',
                              ),
                              _InfoRow(
                                icon: Icons.access_time_outlined,
                                text: _openingHours(details),
                              ),
                              if (details?.description != null)
                                _InfoRow(
                                  icon: Icons.info_outline_rounded,
                                  text: details!.description!,
                                ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: PatifyTheme.space12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(PatifyTheme.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Randevu Al',
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: PatifyTheme.space4),
                                  Text(
                                    'Seçtiğin günde açık olan gerçek slotlar listelenir.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(_formatDate(_selectedDate)),
                            ),
                          ],
                        ),
                        const SizedBox(height: PatifyTheme.space16),
                        if (_authToken == null || _authToken!.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(PatifyTheme.space12),
                            decoration: BoxDecoration(
                              color: PatifyTheme.accentSoft,
                              borderRadius:
                                  BorderRadius.circular(PatifyTheme.radius16),
                            ),
                            child: Text(
                              'Randevu oluşturmak için giriş yapman gerekiyor.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: PatifyTheme.textPrimary,
                              ),
                            ),
                          ),
                        if (_authToken != null && _authRole != 'USER') ...[
                          Container(
                            margin: const EdgeInsets.only(
                              top: PatifyTheme.space12,
                            ),
                            padding: const EdgeInsets.all(PatifyTheme.space12),
                            decoration: BoxDecoration(
                              color: PatifyTheme.primarySoft,
                              borderRadius:
                                  BorderRadius.circular(PatifyTheme.radius16),
                            ),
                            child: Text(
                              'Bu oturumla görüntüleme yapabilirsin; randevu alma sadece normal kullanıcı hesabında açık.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: PatifyTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: PatifyTheme.space16),
                        if (_slotsLoading)
                          const Padding(
                            padding: EdgeInsets.all(PatifyTheme.space24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_slotError != null)
                          Text(_slotError!, style: theme.textTheme.bodyMedium)
                        else if (_availableSlots.isEmpty)
                          Text(
                            'Bu tarih için açık randevu slotu bulunmuyor.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          Wrap(
                            spacing: PatifyTheme.space12,
                            runSpacing: PatifyTheme.space12,
                            children: _availableSlots.map((slot) {
                              final selected = _selectedSlot?.id == slot.id;
                              return ChoiceChip(
                                label: Text(_formatTime(slot.startTime)),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() => _selectedSlot = slot);
                                },
                              );
                            }).toList(),
                          ),
                        if (_selectedSlot != null) ...[
                          const SizedBox(height: PatifyTheme.space16),
                          Container(
                            padding: const EdgeInsets.all(PatifyTheme.space16),
                            decoration: BoxDecoration(
                              color: PatifyTheme.secondarySoft,
                              borderRadius:
                                  BorderRadius.circular(PatifyTheme.radius16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seçilen saat: ${_formatTime(_selectedSlot!.startTime)}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (_selectedSlot!.note != null &&
                                    _selectedSlot!.note!.isNotEmpty) ...[
                                  const SizedBox(height: PatifyTheme.space8),
                                  Text(
                                    _selectedSlot!.note!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: PatifyTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: PatifyTheme.space16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _booking ? null : _bookSelectedSlot,
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
                            label: Text(
                              _booking ? 'İşleniyor...' : 'Randevuyu Onayla',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _openingHours(PlaceDetails? details) {
    final items = details?.weekdayText ?? const <String>[];
    if (items.isEmpty) {
      return 'Çalışma saatleri bilgisi yok';
    }
    return items.join(' | ');
  }

  String _friendlyLoadError(Object error) {
    final message = error.toString();
    if (message.contains('404')) {
      return 'Randevu servisi henüz hazır görünmüyor. Backend uygulamasını yeniden başlatıp tekrar dene.';
    }
    return 'Uygun slotlar alınamadı. Lütfen daha sonra tekrar dene.';
  }

  String _friendlyBookingError(Object error) {
    final message = error.toString();
    if (message.contains('AUTH_TOKEN_MISSING') ||
        message.contains('AUTHORIZATION_REQUIRED')) {
      return 'Randevu almak için önce giriş yapman gerekiyor.';
    }
    if (message.contains('USER_ROLE_REQUIRED')) {
      return 'Randevu alma işlemi sadece normal kullanıcı hesapları için açık.';
    }
    if (message.contains('APPOINTMENT_SLOT_NOT_AVAILABLE')) {
      return 'Bu slot az önce doldu veya artık uygun değil. Liste yenilendi.';
    }
    return 'Randevu oluşturulamadı. Lütfen tekrar dene.';
  }

  void _showMessage(String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? PatifyTheme.danger : null,
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PatifyTheme.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PatifyTheme.textSecondary),
          const SizedBox(width: PatifyTheme.space8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
