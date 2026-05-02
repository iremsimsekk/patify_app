import 'package:flutter/material.dart';

import '../models/appointment_slot.dart';
import '../services/appointment_service.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';

class VeterinarianCalendarScreen extends StatefulWidget {
  const VeterinarianCalendarScreen({
    super.key,
    required this.claimStatus,
    required this.onSlotsChanged,
  });

  final VeterinarianClaimStatusResponse? claimStatus;
  final Future<void> Function() onSlotsChanged;

  @override
  State<VeterinarianCalendarScreen> createState() =>
      _VeterinarianCalendarScreenState();
}

class _VeterinarianCalendarScreenState
    extends State<VeterinarianCalendarScreen> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  bool _loading = false;
  String? _error;
  VeterinarianDaySlots? _daySlots;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant VeterinarianCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.claimStatus?.status != widget.claimStatus?.status) {
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.claimStatus?.isApproved != true) {
      setState(() {
        _loading = false;
        _error = null;
        _daySlots = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AppointmentService.fetchVeterinarianSlots(
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() => _daySlots = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space16,
          PatifyTheme.space20,
          PatifyTheme.space28,
        ),
        children: [
          Text('Takvim', style: theme.textTheme.headlineSmall),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            'Seçtiğin gün için açılan slotları ve alınan randevuları yönet.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PatifyTheme.space16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seçili gün', style: theme.textTheme.labelLarge),
                        const SizedBox(height: PatifyTheme.space4),
                        Text(
                          _formatDate(_selectedDate),
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Gün seç'),
                  ),
                ],
              ),
            ),
          ),
          if (widget.claimStatus?.isApproved != true) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Klinik onayı gerekiyor',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: PatifyTheme.space8),
                    Text(
                      'Takvim ve randevu yönetimi klinik onayı tamamlandıktan sonra açılacak.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_loading) ...[
            const Padding(
              padding: EdgeInsets.all(PatifyTheme.space24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (_error != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Text(_error!, style: theme.textTheme.bodyMedium),
              ),
            ),
          ] else ...[
            _buildSummary(theme),
            const SizedBox(height: PatifyTheme.space12),
            ...((_daySlots?.slots ?? const <AppointmentSlot>[])
                .map(_buildSlotCard)
                .toList()),
            if ((_daySlots?.slots ?? const <AppointmentSlot>[]).isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(PatifyTheme.space16),
                  child: Text(
                    'Bu gün için henüz slot açılmamış.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final summary = _daySlots?.summary;
    if (summary == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _CountCard(
            title: 'Müsait',
            value: summary.availableSlots.toString(),
            accent: PatifyTheme.success,
          ),
        ),
        const SizedBox(width: PatifyTheme.space12),
        Expanded(
          child: _CountCard(
            title: 'Alınmış',
            value: summary.bookedSlots.toString(),
            accent: PatifyTheme.primary,
          ),
        ),
        const SizedBox(width: PatifyTheme.space12),
        Expanded(
          child: _CountCard(
            title: 'İptal',
            value: summary.cancelledSlots.toString(),
            accent: PatifyTheme.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(AppointmentSlot slot) {
    final theme = Theme.of(context);
    final color = switch (slot.status) {
      'BOOKED' => PatifyTheme.primary,
      'CANCELLED' => PatifyTheme.danger,
      _ => PatifyTheme.success,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PatifyTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatClock(slot.startTime)} - ${_formatClock(slot.endTime)}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PatifyTheme.space12,
                    vertical: PatifyTheme.space8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                  ),
                  child: Text(
                    slot.status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (slot.note != null && slot.note!.isNotEmpty) ...[
              const SizedBox(height: PatifyTheme.space8),
              Text(slot.note!, style: theme.textTheme.bodyMedium),
            ],
            if (slot.isBooked) ...[
              const SizedBox(height: PatifyTheme.space12),
              Text(
                'Randevu sahibi',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: PatifyTheme.space4),
              Text(
                slot.bookedByFullName.isNotEmpty
                    ? slot.bookedByFullName
                    : 'İsim bilgisi yok',
                style: theme.textTheme.bodyLarge,
              ),
              if (slot.bookedByEmail != null) ...[
                const SizedBox(height: PatifyTheme.space4),
                Text(slot.bookedByEmail!, style: theme.textTheme.bodyMedium),
              ],
            ],
            if (slot.isAvailable) ...[
              const SizedBox(height: PatifyTheme.space12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancelSlot(slot),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Boş slotu iptal et'),
                ),
              ),
            ],
            if (slot.isBooked) ...[
              const SizedBox(height: PatifyTheme.space8),
              Text(
                'BOOKED slot iptali yakında daha güvenli bir akışla desteklenecek.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PatifyTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: _selectedDate,
    );
    if (picked == null) return;
    setState(() => _selectedDate = DateUtils.dateOnly(picked));
    await _load();
  }

  Future<void> _cancelSlot(AppointmentSlot slot) async {
    try {
      await AppointmentService.cancelVeterinarianSlot(slot.id);
      await widget.onSlotsChanged();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot iptal edildi.')),
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

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('BOOKED_SLOT_CANCEL_NOT_SUPPORTED')) {
      return 'Alınmış randevular için iptal akışı henüz açılmadı.';
    }
    if (message.contains('VETERINARIAN_CLAIM_APPROVAL_REQUIRED')) {
      return 'Klinik onayı olmadan takvim görüntülenemez.';
    }
    return 'Takvim verileri alınamadı. Lütfen tekrar dene.';
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

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PatifyTheme.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }
}
