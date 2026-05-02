import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';

enum _SlotCreateMode { singleDay, weekly }

class VeterinarianCreateSlotsScreen extends StatefulWidget {
  const VeterinarianCreateSlotsScreen({
    super.key,
    required this.claimStatus,
    required this.onSlotsCreated,
  });

  final VeterinarianClaimStatusResponse? claimStatus;
  final Future<void> Function() onSlotsCreated;

  @override
  State<VeterinarianCreateSlotsScreen> createState() =>
      _VeterinarianCreateSlotsScreenState();
}

class _VeterinarianCreateSlotsScreenState
    extends State<VeterinarianCreateSlotsScreen> {
  final _noteController = TextEditingController();

  _SlotCreateMode _mode = _SlotCreateMode.singleDay;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  int _slotDuration = 30;
  final Set<int> _selectedWeekdays = <int>{};
  bool _saving = false;

  static const Map<int, String> _weekdayLabels = {
    DateTime.monday: 'Pazartesi',
    DateTime.tuesday: 'Salı',
    DateTime.wednesday: 'Çarşamba',
    DateTime.thursday: 'Perşembe',
    DateTime.friday: 'Cuma',
    DateTime.saturday: 'Cumartesi',
    DateTime.sunday: 'Pazar',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = widget.claimStatus?.isApproved == true;

    return SafeArea(
      top: false,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          PatifyTheme.space20,
          PatifyTheme.space16,
          PatifyTheme.space20,
          PatifyTheme.space28,
        ),
        children: [
          Text('Slot Aç', style: theme.textTheme.headlineSmall),
          const SizedBox(height: PatifyTheme.space8),
          Text(
            'Uygun saat aralığını seçerek tek gün veya seçtiğin hafta içinde toplu müsaitlik oluşturabilirsin.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PatifyTheme.space20),
          if (!approved)
            const _LockedCard(
              message:
                  'Klinik onayı tamamlanmadan yeni randevu slotu açılamaz.',
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PatifyTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Yeni müsaitlik', style: theme.textTheme.titleMedium),
                    const SizedBox(height: PatifyTheme.space16),
                    SegmentedButton<_SlotCreateMode>(
                      segments: const [
                        ButtonSegment(
                          value: _SlotCreateMode.singleDay,
                          label: Text('Tek gün'),
                          icon: Icon(Icons.calendar_today_outlined),
                        ),
                        ButtonSegment(
                          value: _SlotCreateMode.weekly,
                          label: Text('Haftalık tekrar'),
                          icon: Icon(Icons.view_week_outlined),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selection) {
                        setState(() => _mode = selection.first);
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    _ResponsiveTimeRow(
                      selectedDate: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      mode: _mode,
                      onPickDate: _pickDate,
                      onPickStart: () => _pickTime(isStart: true),
                      onPickEnd: () => _pickTime(isStart: false),
                      formatDate: _formatDate,
                      formatTime: _formatTime,
                    ),
                    if (_mode == _SlotCreateMode.weekly) ...[
                      const SizedBox(height: PatifyTheme.space16),
                      Text(
                        'Haftanın günleri',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: PatifyTheme.space8),
                      Wrap(
                        spacing: PatifyTheme.space8,
                        runSpacing: PatifyTheme.space8,
                        children: _weekdayLabels.entries.map((entry) {
                          final selected =
                              _selectedWeekdays.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: selected,
                            onSelected: (_) => _toggleWeekday(entry.key),
                          );
                        }).toList(growable: false),
                      ),
                      const SizedBox(height: PatifyTheme.space12),
                      Container(
                        padding: const EdgeInsets.all(PatifyTheme.space16),
                        decoration: BoxDecoration(
                          color: PatifyTheme.accentSoft,
                          borderRadius:
                              BorderRadius.circular(PatifyTheme.radius16),
                        ),
                        child: Text(
                          'Öğle arası bırakmak isterseniz sabah ve öğleden sonra için iki ayrı slot aralığı oluşturabilirsiniz.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: PatifyTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: PatifyTheme.space12),
                    DropdownButtonFormField<int>(
                      initialValue: _slotDuration,
                      items: const [15, 30, 45, 60]
                          .map(
                            (duration) => DropdownMenuItem(
                              value: duration,
                              child: Text('$duration dakika'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _slotDuration = value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Slot süresi',
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Not',
                        hintText: 'Örn. aşı kontrolü, cerrahi öncesi görüşme',
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    Container(
                      padding: const EdgeInsets.all(PatifyTheme.space16),
                      decoration: BoxDecoration(
                        color: PatifyTheme.secondarySoft,
                        borderRadius:
                            BorderRadius.circular(PatifyTheme.radius16),
                      ),
                      child: Text(
                        _previewText(),
                        softWrap: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: PatifyTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_task_outlined),
                        label: Text(
                          _saving
                              ? 'Oluşturuluyor...'
                              : _mode == _SlotCreateMode.weekly
                                  ? 'Haftalık slotları oluştur'
                                  : 'Slotları oluştur',
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
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: _selectedDate,
    );
    if (picked == null) return;
    setState(() => _selectedDate = DateUtils.dateOnly(picked));
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
    });
  }

  Future<void> _submit() async {
    if (!_isRangeValid()) {
      _showMessage('Bitiş saati başlangıç saatinden sonra olmalı.', true);
      return;
    }
    if (_selectedDate.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      _showMessage('Geçmiş tarih veya saat için randevu açılamaz.', true);
      return;
    }
    if (_mode == _SlotCreateMode.singleDay &&
        !_isStartTimeInFuture(_selectedDate)) {
      _showMessage(
        'Bugün için yalnızca mevcut saatten sonraki randevular oluşturulabilir.',
        true,
      );
      return;
    }
    if (_mode == _SlotCreateMode.weekly && _selectedWeekdays.isEmpty) {
      _showMessage('Haftalık modda en az bir gün seçmelisiniz.', true);
      return;
    }

    setState(() => _saving = true);
    try {
      if (_mode == _SlotCreateMode.singleDay) {
        final result = await AppointmentService.createBulkSlots(
          date: _selectedDate,
          startTime: _formatTimeApi(_startTime),
          endTime: _formatTimeApi(_endTime),
          slotDurationMinutes: _slotDuration,
          note: _noteController.text,
        );
        await widget.onSlotsCreated();
        if (!mounted) return;
        _showMessage(
          result.message.isNotEmpty
              ? result.message
              : '${result.createdCount} adet slot oluşturuldu.',
          false,
        );
      } else {
        final result = await _createWeeklySlots();
        await widget.onSlotsCreated();
        if (!mounted) return;
        if (result.failedDates.isEmpty && result.messages.isEmpty) {
          _showMessage('Haftalık randevu slotları oluşturuldu.', false);
        } else {
          _showMessage(
            [
              if (result.totalCreated > 0)
                '${result.totalCreated} slot oluşturuldu.',
              ...result.messages,
              if (result.failedDates.isNotEmpty)
                'İşlenemeyen günler: ${result.failedDates.join(', ')}',
            ].join(' '),
            result.failedDates.isNotEmpty,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyError(error), true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<_WeeklyCreateResult> _createWeeklySlots() async {
    final dates = _weeklyDates();
    var totalCreated = 0;
    final failedDates = <String>[];
    final messages = <String>[];

    for (final date in dates) {
      try {
        final result = await AppointmentService.createBulkSlots(
          date: date,
          startTime: _formatTimeApi(_startTime),
          endTime: _formatTimeApi(_endTime),
          slotDurationMinutes: _slotDuration,
          note: _noteController.text,
        );
        totalCreated += result.createdCount;
        if (result.message.isNotEmpty &&
            (result.skippedPastCount > 0 || result.conflictingCount > 0)) {
          messages.add('${_formatDate(date)}: ${result.message}');
        }
      } catch (_) {
        failedDates.add(_formatDate(date));
      }
    }

    return _WeeklyCreateResult(
      totalCreated: totalCreated,
      failedDates: failedDates,
      messages: messages,
    );
  }

  List<DateTime> _weeklyDates() {
    final monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - DateTime.monday),
    );

    final dates = _selectedWeekdays
        .map((weekday) => monday.add(Duration(days: weekday - DateTime.monday)))
        .where((date) =>
            !date.isBefore(DateUtils.dateOnly(DateTime.now())) ||
            DateUtils.isSameDay(date, DateTime.now()))
        .toList()
      ..sort();
    return dates;
  }

  bool _isRangeValid() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return endMinutes > startMinutes;
  }

  bool _isStartTimeInFuture(DateTime date) {
    final candidate = DateTime(
      date.year,
      date.month,
      date.day,
      _startTime.hour,
      _startTime.minute,
    );
    return candidate.isAfter(DateTime.now());
  }

  String _previewText() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final range = endMinutes - startMinutes;
    final count = range > 0 ? range ~/ _slotDuration : 0;

    if (_mode == _SlotCreateMode.weekly) {
      final selectedLabels =
          _selectedWeekdays.map((day) => _weekdayLabels[day]!).join(', ');
      return '${_formatWeekRange()} haftasında ${selectedLabels.isEmpty ? 'gün seçilmedi' : selectedLabels} için yaklaşık her gün $count slot oluşur.';
    }

    return '${_formatDate(_selectedDate)} günü ${_formatTime(_startTime)} - ${_formatTime(_endTime)} aralığında yaklaşık $count slot oluşur.';
  }

  String _formatWeekRange() {
    final monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - DateTime.monday),
    );
    final sunday = monday.add(const Duration(days: 6));
    return '${_formatDate(monday)} - ${_formatDate(sunday)}';
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('VETERINARIAN_CLAIM_APPROVAL_REQUIRED')) {
      return 'Önce klinik onayının tamamlanması gerekiyor.';
    }
    if (message.contains('APPOINTMENT_SLOT_CONFLICT')) {
      return 'Seçtiğiniz aralıkta çakışan slotlar var. Farklı bir saat aralığı deneyin.';
    }
    if (message.contains('PAST_APPOINTMENT_SLOT_CREATION_NOT_ALLOWED')) {
      return 'Geçmiş tarih veya saat için randevu slotu oluşturulamaz.';
    }
    if (message.contains('INVALID_SLOT_DURATION')) {
      return 'Slot süresi 15, 30, 45 veya 60 dakika olmalı.';
    }
    return 'Slotlar oluşturulamadı. Lütfen tekrar dene.';
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

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeApi(TimeOfDay value) => _formatTime(value);
}

class _ResponsiveTimeRow extends StatelessWidget {
  const _ResponsiveTimeRow({
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.onPickDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.formatDate,
    required this.formatTime,
  });

  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final _SlotCreateMode mode;
  final VoidCallback onPickDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String Function(DateTime) formatDate;
  final String Function(TimeOfDay) formatTime;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        mode == _SlotCreateMode.weekly ? 'Başlangıç tarihi' : 'Tarih';

    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumn = constraints.maxWidth < 560;
        final children = [
          _ActionField(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            value: formatDate(selectedDate),
            onTap: onPickDate,
          ),
          _ActionField(
            icon: Icons.schedule_outlined,
            label: 'Başlangıç',
            value: formatTime(startTime),
            onTap: onPickStart,
          ),
          _ActionField(
            icon: Icons.schedule_send_outlined,
            label: 'Bitiş',
            value: formatTime(endTime),
            onTap: onPickEnd,
          ),
        ];

        if (useColumn) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const SizedBox(height: PatifyTheme.space12),
              ],
            ],
          );
        }

        return Column(
          children: [
            children.first,
            const SizedBox(height: PatifyTheme.space12),
            Row(
              children: [
                Expanded(child: children[1]),
                const SizedBox(width: PatifyTheme.space12),
                Expanded(child: children[2]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActionField extends StatelessWidget {
  const _ActionField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PatifyTheme.radius16),
      child: Ink(
        padding: const EdgeInsets.all(PatifyTheme.space16),
        decoration: BoxDecoration(
          border: Border.all(color: PatifyTheme.border),
          borderRadius: BorderRadius.circular(PatifyTheme.radius16),
        ),
        child: Row(
          children: [
            Icon(icon, color: PatifyTheme.primary),
            const SizedBox(width: PatifyTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: PatifyTheme.space4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PatifyTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Klinik onayı gerekiyor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: PatifyTheme.space8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCreateResult {
  const _WeeklyCreateResult({
    required this.totalCreated,
    required this.failedDates,
    required this.messages,
  });

  final int totalCreated;
  final List<String> failedDates;
  final List<String> messages;
}
