import 'package:flutter/material.dart';

import '../services/appointment_service.dart';
import '../services/google_places_service.dart';
import '../services/institution_api_service.dart';
import '../theme/patify_theme.dart';
import '../widgets/patify_user_bottom_nav.dart';
import 'book_appointment_screen.dart';

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
  bool _checkingAvailability = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        InstitutionApiService.fetchInstitutionDetails(widget.placeId);
  }

  Future<void> _openBookingFlow(String clinicName) async {
    final institutionId = int.tryParse(widget.placeId);
    if (institutionId == null) {
      _showMessage('Bu veterinerin randevu bilgisi bulunamadı.', true);
      return;
    }

    setState(() => _checkingAvailability = true);
    try {
      final status = await AppointmentService.fetchAvailabilityStatus(
        institutionId: institutionId,
      );
      if (!mounted) return;
      if (!status.approvedVeterinarianConnected) {
        _showMessage('Bu veterinerin randevu bilgisi bulunamadı.', true);
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(
            institutionId: institutionId,
            clinicName: clinicName,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Bu veterinerin randevu bilgisi bulunamadı.', true);
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      bottomNavigationBar: const PatifyUserBottomNav(
        current: PatifyUserNavItem.services,
      ),
      body: FutureBuilder<PlaceDetails>(
        future: _detailsFuture,
        builder: (context, snap) {
          final loading = snap.connectionState != ConnectionState.done;
          final details = snap.data;
          final clinicName = details?.name ?? widget.title;

          return ListView(
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
                  child: loading
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
                              clinicName,
                              style: theme.textTheme.headlineSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: PatifyTheme.space12),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              details?.formattedAddress ?? 'Adres bilgisi yok',
                            ),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              details?.phone ?? 'Telefon bilgisi yok',
                            ),
                            _buildInfoRow(
                              Icons.mail_outline_rounded,
                              details?.email ?? 'E-posta bilgisi yok',
                            ),
                            _buildInfoRow(
                              Icons.access_time_outlined,
                              _openingHours(details),
                            ),
                            if (details?.website != null)
                              _buildInfoRow(Icons.language, details!.website!),
                            if (details?.description != null)
                              _buildInfoRow(
                                Icons.info_outline_rounded,
                                details!.description!,
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: PatifyTheme.space16),
              Container(
                padding: const EdgeInsets.all(PatifyTheme.space20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(PatifyTheme.radius24),
                  border: Border.all(color: PatifyTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Randevu', style: theme.textTheme.titleLarge),
                    const SizedBox(height: PatifyTheme.space8),
                    Text(
                      'Sistemde onaylı veteriner bağlantısı varsa gerçek slotlarla randevu oluşturabilirsin.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: PatifyTheme.space16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _checkingAvailability
                            ? null
                            : () => _openBookingFlow(clinicName),
                        icon: _checkingAvailability
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          _checkingAvailability
                              ? 'Kontrol ediliyor...'
                              : 'Randevu Al',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _openingHours(PlaceDetails? details) {
    final items = details?.weekdayText ?? const <String>[];
    if (items.isEmpty) return 'Çalışma saatleri bilgisi yok';
    return items.join(' | ');
  }

  void _showMessage(String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? PatifyTheme.danger : null,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PatifyTheme.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PatifyTheme.textSecondary),
          const SizedBox(width: PatifyTheme.space8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
