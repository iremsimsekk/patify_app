import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import '../services/veterinarian_claim_service.dart';
import '../theme/patify_theme.dart';

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

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  int _slotDuration = 30;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = widget.claimStatus?.isApproved == true;

    return ListView(
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
          'Uygun saat aralığı seçildiğinde sistem randevu slotlarını otomatik üretir.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: PatifyTheme.space20),
        if (!approved)
          const _LockedCard(
            message: 'Klinik onayı tamamlanmadan yeni randevu slotu açılamaz.',
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
                  _ActionField(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tarih',
                    value: _formatDate(_selectedDate),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: PatifyTheme.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionField(
                          icon: Icons.schedule_outlined,
                          label: 'Başlangıç',
                          value: _formatTime(_startTime),
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: PatifyTheme.space12),
                      Expanded(
                        child: _ActionField(
                          icon: Icons.schedule_send_outlined,
                          label: 'Bitiş',
                          value: _formatTime(_endTime),
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
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
                      borderRadius: BorderRadius.circular(PatifyTheme.radius16),
                    ),
                    child: Text(
                      _previewText(),
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
                          _saving ? 'Oluşturuluyor...' : 'Slotları oluştur'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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

  Future<void> _submit() async {
    if (!_isRangeValid()) {
      _showMessage('Bitiş saati başlangıç saatinden sonra olmalı.', true);
      return;
    }

    setState(() => _saving = true);
    try {
      final createdCount = await AppointmentService.createBulkSlots(
        date: _selectedDate,
        startTime: _formatTimeApi(_startTime),
        endTime: _formatTimeApi(_endTime),
        slotDurationMinutes: _slotDuration,
        note: _noteController.text,
      );
      await widget.onSlotsCreated();
      if (!mounted) return;
      _showMessage('$createdCount adet slot oluşturuldu.', false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyError(error), true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isRangeValid() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return endMinutes > startMinutes;
  }

  String _previewText() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final range = endMinutes - startMinutes;
    final count = range > 0 ? range ~/ _slotDuration : 0;
    return '${_formatDate(_selectedDate)} günü ${_formatTime(_startTime)} - ${_formatTime(_endTime)} aralığında yaklaşık $count slot oluşur.';
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('VETERINARIAN_CLAIM_APPROVAL_REQUIRED')) {
      return 'Önce klinik onayının tamamlanması gerekiyor.';
    }
    if (message.contains('APPOINTMENT_SLOT_CONFLICT')) {
      return 'Seçtiğin aralıkta çakışan slotlar var. Farklı bir saat aralığı dene.';
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
                  Text(value, style: Theme.of(context).textTheme.bodyMedium),
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
            Text('Klinik onayı gerekiyor',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: PatifyTheme.space8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
