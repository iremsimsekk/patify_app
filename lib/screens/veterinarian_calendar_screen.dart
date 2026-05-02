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
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
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
      final day = await AppointmentService.fetchVeterinarianSlots(
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() {
        _daySlots = day;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectDate(DateTime date) async {
    setState(() => _selectedDate = DateUtils.dateOnly(date));
    await _load();
  }

  void _changeMonth(int offset) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    setState(() {
      _visibleMonth = next;
      if (_selectedDate.year != next.year ||
          _selectedDate.month != next.month) {
        _selectedDate = DateTime(next.year, next.month, 1);
      }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            'Aylık görünüm üzerinden gün seç, slot yoğunluğunu gör ve randevuları güvenle yönet.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space20),
          if (widget.claimStatus?.isApproved != true)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Klinik onayı gerekiyor.',
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
            )
          else if (_loading)
            const Padding(
              padding: EdgeInsets.all(PatifyTheme.space24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Text(_error!, style: theme.textTheme.bodyMedium),
              ),
            )
          else ...[
            _buildCalendar(theme),
            const SizedBox(height: PatifyTheme.space16),
            _buildSummary(),
            const SizedBox(height: PatifyTheme.space16),
            Text(
              '${_formatDate(_selectedDate)} günü slotları',
              style: theme.textTheme.titleMedium,
            ),
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

  Widget _buildCalendar(ThemeData theme) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = (firstDay.weekday + 6) % 7;

    final cells = <Widget>[
      for (var i = 0; i < leadingEmpty; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _CalendarDayCell(
          date: DateTime(_visibleMonth.year, _visibleMonth.month, day),
          selected: DateUtils.isSameDay(
            DateTime(_visibleMonth.year, _visibleMonth.month, day),
            _selectedDate,
          ),
          isToday: DateUtils.isSameDay(
            DateTime(_visibleMonth.year, _visibleMonth.month, day),
            DateTime.now(),
          ),
          onTap: () => _selectDate(
            DateTime(_visibleMonth.year, _visibleMonth.month, day),
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(PatifyTheme.space16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius24),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  _formatMonthTitle(_visibleMonth),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: PatifyTheme.space12),
          const Row(
            children: [
              _WeekdayLabel(label: 'Pzt'),
              _WeekdayLabel(label: 'Sal'),
              _WeekdayLabel(label: 'Çar'),
              _WeekdayLabel(label: 'Per'),
              _WeekdayLabel(label: 'Cum'),
              _WeekdayLabel(label: 'Cmt'),
              _WeekdayLabel(label: 'Paz'),
            ],
          ),
          const SizedBox(height: PatifyTheme.space8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: PatifyTheme.space8,
              crossAxisSpacing: PatifyTheme.space8,
              mainAxisExtent: 52,
            ),
            itemBuilder: (context, index) => cells[index],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final summary = _daySlots?.summary;
    if (summary == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 540
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: PatifyTheme.space12,
          runSpacing: PatifyTheme.space12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _CountCard(
                title: 'Toplam',
                value: summary.totalSlots.toString(),
                accent: PatifyTheme.info,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CountCard(
                title: 'Boş',
                value: summary.availableSlots.toString(),
                accent: PatifyTheme.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CountCard(
                title: 'Dolu',
                value: summary.bookedSlots.toString(),
                accent: PatifyTheme.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CountCard(
                title: 'İptal',
                value: summary.cancelledSlots.toString(),
                accent: PatifyTheme.danger,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlotCard(AppointmentSlot slot) {
    final theme = Theme.of(context);
    final color = switch (slot.status) {
      'BOOKED' => PatifyTheme.primary,
      'CANCELLED' => PatifyTheme.danger,
      _ => PatifyTheme.success,
    };
    final label = switch (slot.status) {
      'BOOKED' => 'Dolu / Randevu Alındı',
      'CANCELLED' => 'İptal Edildi',
      _ => 'Boş / Müsait',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PatifyTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: PatifyTheme.space12,
              runSpacing: PatifyTheme.space12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_formatClock(slot.startTime)} - ${_formatClock(slot.endTime)}',
                  style: theme.textTheme.titleMedium,
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
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            if (slot.note?.isNotEmpty == true) ...[
              const SizedBox(height: PatifyTheme.space8),
              Text(slot.note!, style: theme.textTheme.bodyMedium),
            ],
            if (slot.isBooked) ...[
              const SizedBox(height: PatifyTheme.space12),
              Text('Randevu sahibi', style: theme.textTheme.labelLarge),
              const SizedBox(height: PatifyTheme.space4),
              Text(
                slot.bookedByFullName.isNotEmpty
                    ? slot.bookedByFullName
                    : 'İsim bilgisi yok',
                style: theme.textTheme.bodyLarge,
              ),
              if (slot.bookedByEmail != null) ...[
                const SizedBox(height: PatifyTheme.space4),
                Text(
                  slot.bookedByEmail!,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium,
                ),
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

  String _formatMonthTitle(DateTime value) {
    const monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${monthNames[value.month - 1]} ${value.year}';
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PatifyTheme.radius16),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? PatifyTheme.primarySoft
                : isToday
                    ? PatifyTheme.secondarySoft
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(PatifyTheme.radius16),
            border: Border.all(
              color: selected
                  ? PatifyTheme.primary
                  : isToday
                      ? PatifyTheme.secondary
                      : PatifyTheme.border,
            ),
          ),
          child: Center(
            child: Text(
              '${date.day}',
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: PatifyTheme.textSecondary,
              ),
        ),
      ),
    );
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }
}
