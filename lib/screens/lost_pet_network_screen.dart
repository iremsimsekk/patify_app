import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/ankara_districts.dart';
import '../data/mock_data.dart';
import '../services/lost_report_service.dart';
import '../theme/patify_theme.dart';
import 'location_picker_screen.dart';
import 'lost_report_detail_screen.dart';

class LostPetNetworkScreen extends StatefulWidget {
  const LostPetNetworkScreen({
    super.key,
    required this.currentUser,
  });

  final AppUser currentUser;

  @override
  State<LostPetNetworkScreen> createState() => _LostPetNetworkScreenState();
}

class _LostPetNetworkScreenState extends State<LostPetNetworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  String _petType = 'Kedi';
  String _district = 'Çankaya';
  PickedLocation? _pickedLocation;
  String? _imageDataUrl;
  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;
  List<LostReportNotification> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _district = widget.currentUser.district ?? _district;
    _loadNotifications();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final location = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (location != null) {
      setState(() => _pickedLocation = location);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 900,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageDataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await LostReportService.notifications(
        email: widget.currentUser.email,
      );
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createReport() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _submitting) return;
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen haritadan konum seç.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final report = await LostReportService.create(
        userEmail: widget.currentUser.email,
        petType: _petType,
        description: _descriptionController.text.trim(),
        contactInfo: _contactController.text.trim(),
        district: _district,
        address: _addressController.text.trim(),
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        imageUrl: _imageDataUrl,
      );
      _descriptionController.clear();
      _contactController.clear();
      _addressController.clear();
      if (!mounted) return;
      setState(() {
        _pickedLocation = null;
        _imageDataUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${report.notificationRecipientCount} kullanıcıya uygulama içi bildirim oluşturuldu.',
          ),
        ),
      );
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('USER_NOT_FOUND')) {
      return 'Kullanıcı bulunamadı. Lütfen tekrar giriş yap.';
    }
    if (message.contains('Connection refused') ||
        message.contains('SocketException')) {
      return 'Sunucuya bağlanılamadı.';
    }
    return 'İşlem tamamlanamadı. Lütfen tekrar dene.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıp Hayvan Ağı'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loading ? null : _loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: const EdgeInsets.all(PatifyTheme.space20),
          children: [
            Container(
              padding: const EdgeInsets.all(PatifyTheme.space20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PatifyTheme.radius24),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.campaign_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: PatifyTheme.space8),
                        Text(
                          'Yeni kayıp ilanı',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    DropdownButtonFormField<String>(
                      initialValue: _petType,
                      decoration: const InputDecoration(labelText: 'Tür'),
                      items: const ['Kedi', 'Köpek', 'Kuş', 'Diğer']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _petType = value);
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    DropdownButtonFormField<String>(
                      initialValue: _district,
                      decoration: const InputDecoration(
                        labelText: 'Semt',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: ankaraDistricts
                          .map(
                            (district) => DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _district = value);
                        }
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Açıklama gerekli.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Kaybolduğu yerin adresi',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Adres bilgisi gerekli.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    OutlinedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(
                        _pickedLocation == null
                            ? 'Haritadan konum seç'
                            : 'Konum seçildi',
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        _imageDataUrl == null
                            ? 'Fotoğraf seç'
                            : 'Fotoğraf seçildi',
                      ),
                    ),
                    const SizedBox(height: PatifyTheme.space12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'İletişim bilgisi',
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'İletişim bilgisi gerekli.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitting ? null : _createReport,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.notifications_active_rounded),
                        label: const Text('Yayınla ve bildir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PatifyTheme.space24),
            Text(
              'Bana gelen bildirimler',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: PatifyTheme.space12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(PatifyTheme.space24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _InfoPanel(
                icon: Icons.wifi_off_rounded,
                text: _errorMessage!,
              )
            else if (_notifications.isEmpty)
              const _InfoPanel(
                icon: Icons.notifications_none_rounded,
                text: 'Henüz kayıp ilan bildirimi yok.',
              )
            else
              ..._notifications.map(
                (notification) => _NotificationTile(
                  notification: notification,
                  currentUser: widget.currentUser,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.currentUser,
  });

  final LostReportNotification notification;
  final AppUser currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
          child: Icon(
            Icons.pets_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          '#${notification.lostReportId}',
          style: theme.textTheme.labelLarge,
        ),
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => LostReportDetailScreen(
                reportId: notification.lostReportId,
                currentUser: currentUser,
              ),
            ),
          );
          if (changed == true && context.mounted) {
            final state =
                context.findAncestorStateOfType<_LostPetNetworkScreenState>();
            state?._loadNotifications();
          }
        },
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PatifyTheme.space20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(PatifyTheme.radius20),
        border: Border.all(color: PatifyTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: PatifyTheme.space12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
